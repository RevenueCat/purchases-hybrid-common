danger.import_dangerfile(github: 'RevenueCat/Dangerfile')

fail_on_generated_edits(["typescript/src/generated/"])

# Prevent experimental/internal native RevenueCat APIs from being laundered into PHC's public
# surface without an explicit, reviewable acknowledgment. See DEVELOPMENT.md for the two
# acknowledgment paths. Full-tree scan (not diff-based), so every future site is caught, not
# just newly-added ones.
NATIVE_OPT_IN_MARKERS = %w[
  ExperimentalPreviewRevenueCatPurchasesAPI
  InternalRevenueCatAPI
  ExperimentalPreviewRevenueCatUIPurchasesAPI
].freeze
NATIVE_MARKER_PATTERN = Regexp.union(NATIVE_OPT_IN_MARKERS)
RAW_MARKER_LINE_PATTERN = /^\s*@(?:#{NATIVE_MARKER_PATTERN})\b/.freeze

# Returns [is_file_scoped, end_index, text] if `lines[start_index]` opens an `@OptIn(`/`@file:OptIn(`
# call, consuming subsequent lines until the parens balance. Handles multi-line argument lists
# (e.g. `@OptIn(\n    InternalRevenueCatAPI::class,\n)`), which a single-line regex would miss entirely.
def opt_in_extent(lines, start_index)
  match = lines[start_index].match(/@(file:)?OptIn\(/)
  return nil unless match

  text = +''
  depth = 0
  index = start_index
  loop do
    fragment = index == start_index ? lines[index][match.begin(0)..] : lines[index]
    text << fragment
    depth += fragment.count('(') - fragment.count(')')
    break if depth <= 0 || index + 1 >= lines.length

    index += 1
  end
  [!match[1].nil?, index, text]
end

# ponytail: the backward scan only recognizes single-line preceding comments/annotations
# (`// ...`, `@Foo(...)`, `* ...`); a multi-line preceding annotation (e.g. a wrapped
# `@Suppress(\n  "A",\n)`) stops the walk one line early. Widen if that pattern shows up for real.
def acknowledgment_block(file, lines, start_index, end_index)
  block_start = start_index
  block_start -= 1 while block_start > 0 && lines[block_start - 1].strip.match?(%r{^(//|@|\*)})
  block = lines[block_start..end_index].join
  block.include?('phc:stable-bridge') ||
    (block.include?('@ExperimentalPreviewHybridCommonAPI') && File.basename(file) =~ /experimental/i)
end

def no_acknowledgment_message(file, line_number)
  "#{file}:#{line_number} opts into a native experimental/internal RevenueCat API without " \
    'acknowledgment. Either annotate the declaration with `@ExperimentalPreviewHybridCommonAPI` ' \
    'and move it into an `experimental*.kt` file (native `Experimental*` markers, the usual case), ' \
    'or add a `// phc:stable-bridge` comment declaring PHC deliberately stabilizes this surface ' \
    '(native `InternalRevenueCatAPI` usage, the usual case).'
end

def phc_kotlin_leak_violations
  violations = []
  Dir.glob('android/*/src/main/**/*.kt').each do |file|
    lines = File.readlines(file)
    index = 0
    while index < lines.length
      extent = opt_in_extent(lines, index)

      if extent
        is_file_scoped, end_index, text = extent
        if text =~ NATIVE_MARKER_PATTERN
          if is_file_scoped
            violations << "#{file}:#{index + 1} uses `@file:OptIn` on a native experimental/internal " \
              'marker; file-level opt-in cannot carry a per-declaration acknowledgment. Move the ' \
              'opt-in to the specific declaration.'
          elsif !acknowledgment_block(file, lines, index, end_index)
            violations << no_acknowledgment_message(file, index + 1)
          end
        end
        index = end_index + 1
        next
      end

      if (lines[index] =~ RAW_MARKER_LINE_PATTERN) && !acknowledgment_block(file, lines, index, index)
        violations << no_acknowledgment_message(file, index + 1)
      end

      index += 1
    end
  end
  violations
end

def phc_gradle_opt_in_loophole_violations
  Dir.glob('android/**/*.gradle{,.kts}').each_with_object([]) do |file, violations|
    File.readlines(file).each_with_index do |line, index|
      next unless line.include?('-opt-in')

      violations << "#{file}:#{index + 1} sets a compiler `-opt-in` flag, which silently opts in " \
        'to a marker repo-wide and bypasses the experimental/internal API gate.'
    end
  end
end

(phc_kotlin_leak_violations + phc_gradle_opt_in_loophole_violations).each { |message| fail(message) }
