; REQUIRES: object-emission
; This test is failing for powerpc64, because a location list for the
; variable 'c' is not generated at all. Temporary marking this test as XFAIL 
; for powerpc, until PR21881 is fixed.
; XFAIL: powerpc64

; RUN: llvm-as -opaque-pointers=0 < %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: llvm-spirv -r %t.spv -o - | llvm-dis -o %t.ll

; RUN: llc -mtriple=%triple -O2  -dwarf-version 2 -filetype=obj < %t.ll | llvm-dwarfdump - | FileCheck %s  --check-prefix=DWARF23
; RUN: llc -mtriple=%triple -O2  -dwarf-version 3 -filetype=obj < %t.ll | llvm-dwarfdump - | FileCheck %s  --check-prefix=DWARF23
; RUN: llc -mtriple=%triple -O2  -dwarf-version 4 -filetype=obj < %t.ll | llvm-dwarfdump - | FileCheck %s  --check-prefix=DWARF4

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

; This is a test for PR21176.
; DW_OP_const <const> doesn't describe a constant value, but a value at a constant address. 
; The proper way to describe a constant value is DW_OP_constu <const>, DW_OP_stack_value.
; For values < 32 we emit the canonical DW_OP_lit<const>.

; Generated with clang -S -emit-llvm -g -O2 test.cpp

; extern int func();
; 
; int main()
; {
;   volatile int c = 13;
;   c = func();
;   return c;
; }

; CHECK: DW_TAG_variable
; CHECK: DW_AT_location
; CHECK-NOT: DW_AT
; DWARF23: DW_OP_lit13{{$}}
; DWARF4: DW_OP_lit13, DW_OP_stack_value{{$}}

; Function Attrs: uwtable
define i32 @main() #0 !dbg !4 {
entry:
  %c = alloca i32, align 4
  tail call void @llvm.dbg.value(metadata i32 13, metadata !10, metadata !16), !dbg !17
  store volatile i32 13, i32* %c, align 4, !dbg !18
  %call = tail call i32 @_Z4funcv(), !dbg !19
  tail call void @llvm.dbg.value(metadata i32 %call, metadata !10, metadata !16), !dbg !17
  store volatile i32 %call, i32* %c, align 4, !dbg !19
  tail call void @llvm.dbg.value(metadata i32* %c, metadata !10, metadata !21), !dbg !17
  %c.0.c.0. = load volatile i32, i32* %c, align 4, !dbg !20
  ret i32 %c.0.c.0., !dbg !20
}

declare i32 @_Z4funcv() #1

; Function Attrs: nounwind readnone
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!12, !13}
!llvm.ident = !{!14}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.6.0 (trunk 223522)", isOptimized: true, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "test.cpp", directory: "/home/kromanova/ngh/ToT_latest/llvm/test/DebugInfo")
!2 = !{}
!4 = distinct !DISubprogram(name: "main", line: 3, isLocal: false, isDefinition: true, flags: DIFlagPrototyped, isOptimized: true, unit: !0, scopeLine: 4, file: !1, scope: !5, type: !6, retainedNodes: !9)
!5 = !DIFile(filename: "test.cpp", directory: "/home/kromanova/ngh/ToT_latest/llvm/test/DebugInfo")
!6 = !DISubroutineType(types: !7)
!7 = !{!8}
!8 = !DIBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!9 = !{!10}
!10 = !DILocalVariable(name: "c", line: 5, scope: !4, file: !5, type: !11)
!11 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !8)
!12 = !{i32 2, !"Dwarf Version", i32 2}
!13 = !{i32 2, !"Debug Info Version", i32 3}
!14 = !{!"clang version 3.6.0 (trunk 223522)"}
!15 = !{i32 13}
!16 = !DIExpression()
!17 = !DILocation(line: 5, column: 16, scope: !4)
!18 = !DILocation(line: 5, column: 3, scope: !4)
!19 = !DILocation(line: 6, column: 7, scope: !4)
!20 = !DILocation(line: 7, column: 3, scope: !4)
!21 = !DIExpression(DW_OP_deref)

