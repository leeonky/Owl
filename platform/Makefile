sys_temp_path=${shell echo "$${SYS_TEMP_PATH:-/tmp}"}

last_run_unit_tests	:=${foreach f, ${shell cat ${sys_temp_path}/last_shunit 2>/dev/null}, ${f}.rpt}
selected_unit_tests	:=${foreach f, ${uts}, ${f}.rpt}
all_unit_tests		:=${foreach f, ${shell find . -name *_test.sh}, ${f}.rpt}
all_new_unit_tests	:=${foreach f, ${shell find . -name *_test.sh}, ${sys_temp_path}/${f}.rpt}

${shell rm -f ${sys_temp_path}/last_shunit}

testnew: ${all_new_unit_tests}
	@echo Test new done!

retest: ${last_run_unit_tests}
	@echo Retest done!

test: ${selected_unit_tests}
	@echo Test done!

testall: ${all_unit_tests}
	@echo Test all done!

${sys_temp_path}/%_test.sh.rpt: %_test.sh %.sh
	@echo '>>>>>>>>>>>>'${<}
	@echo ${<} >> ${sys_temp_path}/last_shunit
	@mkdir -p "${shell dirname ${@}}"
	@./${*}_test.sh | tee ${@}

%_test.sh.rpt: %_test.sh %.sh
	@echo '>>>>>>>>>>>>'${<}
	@echo ${<} >> ${sys_temp_path}/last_shunit
	@./${*}_test.sh
