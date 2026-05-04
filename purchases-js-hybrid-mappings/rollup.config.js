import typescript from '@rollup/plugin-typescript';
import dts from 'rollup-plugin-dts';
import { defineConfig } from 'rollup';
import { nodeResolve } from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';

const jsPlugins = () => [
  nodeResolve(),
  typescript({
    tsconfig: './tsconfig.json',
    declaration: false,
    declarationMap: false,
    sourceMap: true,
    inlineSources: true
  }),
  terser()
];

export default defineConfig([
  {
    input: 'src/index.ts',
    output: {
      dir: 'dist',
      format: 'esm',
      entryFileNames: 'index.js',
      chunkFileNames: 'chunks/[name]-[hash].js',
      sourcemap: true
    },
    plugins: jsPlugins()
  },
  {
    input: 'src/index.ts',
    output: {
      file: 'dist/index.umd.js',
      format: 'umd',
      name: 'PurchasesHybridMappings',
      inlineDynamicImports: true,
      sourcemap: true
    },
    plugins: jsPlugins()
  },
  {
    input: 'src/index.ts',
    output: {
      file: 'dist/index.d.ts',
      format: 'esm'
    },
    plugins: [
      dts({
        compilerOptions: {
          baseUrl: './',
          paths: {}
        }
      })
    ]
  }
]);
