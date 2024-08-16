#!/bin/bash
EESSI_VERSION="2023.06"
export LMOD_PAGER=cat

# initialize assert framework
if [ ! -d assert.sh ]; then
	echo "assert.sh not cloned."
	echo ""
	echo "run \`git clone https://github.com/lehmannro/assert.sh.git\`"
	exit 1
fi
. assert.sh/assert.sh

SHELLS=$@

for shell in ${SHELLS[@]}; do
	echo = | awk 'NF += (OFS = $_) + 100'
	echo  RUNNING TESTS FOR SHELL: $shell
	echo = | awk 'NF += (OFS = $_) + 100'

	# TEST 1: Source Script and check Module Output
	assert "$shell -c 'source init/$shell' 2>&1 " "EESSI/$EESSI_VERSION loaded successfully"
	# TEST 2: Check PS1 Prompt (Previous exported)
	PROMPT="${shell^^}_PROMPT"
	assert "echo ${!PROMPT}" "{EESSI $EESSI_VERSION}"
	# Test 3: Check module overview
	MODULE_SECTIONS=($($shell -c "source init/$shell 2>/dev/null; module ov 2>&1 | grep -e '---'"))
	assert "echo ${MODULE_SECTIONS[1]}" "/cvmfs/software.eessi.io/versions/$EESSI_VERSION/software/linux/x86_64/intel/haswell/modules/all"
	assert "echo ${MODULE_SECTIONS[4]}" "/home/eessi/EESSI_testing/modules"
	# Test 4: Load Python module and check version and path
	command="$shell -c 'source init/$shell 2>/dev/null; module load Python/3.10.8-GCCcore-12.2.0; python --version'"
	expected="Python 3.10.8"
	assert "$command" "$expected"
	command="$shell -c 'source init/$shell 2>/dev/null; module load Python/3.10.8-GCCcore-12.2.0; which python'"
	expected="/cvmfs/software.eessi.io/versions/$EESSI_VERSION/software/linux/x86_64/intel/haswell/software/Python/3.10.8-GCCcore-12.2.0/bin/python"
	assert "$command" "$expected"
done

#ZSH TESTS
#assert "zsh -c 'source init/zsh' 2>&1 " "EESSI/$EESSI_VERSION loaded successfully"
#assert "echo $ZSH_PROMPT" "{EESSI $EESSI_VERSION}"

#KSH TESTS
#assert "ksh -c 'source init/ksh' 2>&1 " "EESSI/$EESSI_VERSION loaded successfully"
#assert "echo $KSH_PROMPT" "{EESSI $EESSI_VERSION}"

#FISH TESTS
#assert "fish -c 'source init/fish' 2>&1 " "EESSI/$EESSI_VERSION loaded successfully"
#assert "echo $FISH_PROMPT" "{EESSI $EESSI_VERSION}"

#CSH TESTS
#assert "csh -c 'source init/csh' 2>&1 " "EESSI/$EESSI_VERSION loaded successfully"
#assert "echo $CSH_PROMPT" "{EESSI $EESSI_VERSION}"

assert_end source_eessi

# RESET PAGER
export LMOD_PAGER=
