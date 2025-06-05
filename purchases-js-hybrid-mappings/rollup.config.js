import typescript from '@rollup/plugin-typescript';
import dts from 'rollup-plugin-dts';
import { defineConfig } from 'rollup';
import { nodeResolve } from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';

export default defineConfig([
  {
    input: 'src/index.ts',
    output: [
      {
        file: 'dist/index.js',
        format: 'esm',
        inlineDynamicImports: true,
        sourcemap: true
      },
      {
        file: 'dist/index.umd.js',
        format: 'umd',
        inlineDynamicImports: true,
        name: 'PurchasesHybridMappings',
        sourcemap: true
      }
    ],
    plugins: [
      nodeResolve(),
      typescript({
        tsconfig: './tsconfig.json',
        declaration: false,
        declarationMap: false,
        sourceMap: true,
        inlineSources: true
      }),
      terser()
    ]
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
