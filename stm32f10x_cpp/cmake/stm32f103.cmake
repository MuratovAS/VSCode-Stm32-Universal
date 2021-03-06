set(FPU_FLAGS "-mfloat-abi=soft")#if hart then  "-mfpu=fpv4-sp-d16"

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	#Оставляем минимум оптимизауий для более удобной отладки, совсем без оптимизации нельзя, иначе не вычисляются constexpr, и это может вызывать переполнение стека (из-за рекурсивных функций)
	set(DEBUG_OPTIMISATION "-fno-auto-inc-dec -fno-branch-count-reg -fno-combine-stack-adjustments -fno-compare-elim -fno-cprop-registers -fno-dce -fno-defer-pop -fno-delayed-branch -fno-dse -fno-forward-propagate -fno-guess-branch-probability -fno-if-conversion -fno-if-conversion2 -fno-inline-functions-called-once -fno-ipa-profile -fno-ipa-pure-const -fno-ipa-reference -fno-merge-constants -fno-move-loop-invariants -fno-omit-frame-pointer -fno-reorder-blocks -fno-shrink-wrap -fno-shrink-wrap-separate -fno-split-wide-types -fno-ssa-backprop -fno-ssa-phiopt -fno-tree-bit-ccp -fno-tree-ccp -fno-tree-ch -fno-tree-coalesce-vars -fno-tree-copy-prop -fno-tree-dce -fno-tree-dominator-opts -fno-tree-dse -fno-tree-forwprop -fno-tree-fre -fno-tree-phiprop -fno-tree-pta -fno-tree-scev-cprop -fno-tree-sink -fno-tree-slsr -fno-tree-sra -fno-tree-ter -fno-unit-at-a-time")
	set(COMMON_FLAGS "-mtpcs-frame -mtpcs-leaf-frame -fno-omit-frame-pointer -O1 ")
	add_definitions(-DUSE_DEBUG=1 -DUSE_ASSERTS=1 -DRTOS_USE_DEBUG=0)
else()
	set(COMMON_FLAGS "-flto -ffat-lto-objects -fno-builtin")
endif()

set(WARNINGS "-Wall") ##-Wextra -Werror -Wno-comment -Wno-unused-parameter
set(COMMON_FLAGS
"-mcpu=cortex-m3  ${FPU_FLAGS} -mthumb -mthumb-interwork -ffunction-sections -fdata-sections \
-fno-common -fmessage-length=0 -specs=nosys.specs -specs=nano.specs ${WARNINGS} ${COMMON_FLAGS} -finput-charset=UTF-8")


SET(CMAKE_CXX_FLAGS "${COMMON_FLAGS} -std=c++17 -Wno-register -fno-exceptions -frtti")
SET(CMAKE_C_FLAGS "${COMMON_FLAGS} -std=gnu11")
