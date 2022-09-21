#!/bin/bash
#
#by:ITdesk
#
#获取当前脚本目录copy脚本之家

#set -x

Source="$0"
while [ -h "$Source"  ]; do
    dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
    Source="$(readlink "$Source")"
    [[ $Source != /*  ]] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m" 


clear
#题库数量
tiku_num=$(cat $dir_file/tiku.txt | grep -n "[0-9]\. " |wc -l)
#记录答题对错
if [ -f $dir_file/tiku_answer_record.txt ];then
	echo ""				
else
	echo -e "你的答题记录\n正确:0\n错误:0" > $dir_file/tiku_answer_record.txt
fi
#当前做到那个题
if [ -f $dir_file/tiku_current.txt ];then
	
	tiku_current=$(cat $dir_file/tiku_current.txt)
	echo -e "$green你上次做到第$tiku_current题，请继续$white"
else
	tiku_current="1"
fi


start() {

	echo ">> 提示：如果你需要从头开始，请执行bash dati.sh init"
	echo ">> 出现如图所示，请查看当前文件夹里的imges文件夹"
	sleep 3
	while [[ "$tiku_num" -ge "$tiku_current" ]];do
		tiku_correct_num=$(grep "正确" $dir_file/tiku_answer_record.txt | awk -F ":" '{print $2}')
		tiku_error_num=$(grep "错误" $dir_file/tiku_answer_record.txt | awk -F ":" '{print $2}')
		clear
		#set -x
		echo "------------------------------"	
		echo "	开始测试考试"
		echo "------------------------------"
		echo -e "${yellow}>> 当前题库共有$green${tiku_num}$yellow题，当前第$green${tiku_current}$yellow题,当前答对$green${tiku_correct_num}$yellow题，答错$red${tiku_error_num}$yellow题。$white"
		echo "------------------------------"		
		#计算当前题库当前题位置
		tiku_current_location=$(cat $dir_file/tiku.txt | grep -n "[0-9]\. " |sed -n "${tiku_current}p" | awk -F ":" '{print $1}')
	
		#计算是否为最后一题
		if [ "$tiku_num" == "$tiku_current" ];then
			tiku_current_next_location_1=$(cat $dir_file/tiku.txt |wc -l)
		else
			#计算题库下一题位置
			tiku_current_next=$(expr ${tiku_current} + 1)
			tiku_current_next_location=$(cat $dir_file/tiku.txt | grep -n "[0-9]\. " |sed -n "${tiku_current_next}p" | awk -F ":" '{print $1}')
			tiku_current_next_location_1=$(expr $tiku_current_next_location - 1)
		fi
		

		sed -n "${tiku_current_location},${tiku_current_next_location_1}p" $dir_file/tiku.txt >/tmp/tiku_topic.txt
		ti_answer=$(cat /tmp/tiku_topic.txt |awk -F "__" '{print $2}'| sed "s/_//g"|sed "s/。//g" | sed 's/[[:space:]]//g'| sed ':t;N;s/\n//;b t')
		ti_sort=$(cat /tmp/tiku_topic.txt | sed "s/__$ti_answer/__/g")

		#ti_numbering=$(cat /tmp/tiku_topic.txt | grep  "[0-9]\. " |awk -F "." '{print  $1}')
		#ti_sort=$(cat /tmp/tiku_topic.txt | sed "s/${ti_numbering}./${tiku_current}./g"| sed "s/__$ti_answer/__/g")
		

		echo -e "$ti_sort\n\n"
		#if [ -z "$ti_answer" ];then
		#	echo -e "当前第$green${tiku_current}题,$red答案一异常$white"
		#	read a
		#else
		#	echo -e "当前第$green${tiku_current}$yellow题,答案为$ti_answer$white"
		#fi
		
		
		read -p "请输入你的答案(字母大写):" answer_if
		if [[ -z "$answer_if" ]];then
			echo "请不要输入空值"
			sleep 2
			echo "$tiku_current" > $dir_file/tiku_current.txt
		else
			if [[ "${ti_answer}" == "${answer_if}" ]];then
				ti_answer_ok=$(grep "正确" $dir_file/tiku_answer_record.txt)
				ti_answer_ok_num=$(echo "$ti_answer_ok" |awk -F ":" '{print $2}')
				ti_answer_ok_num_1=$(expr $ti_answer_ok_num + 1)
				sed -i "s/$ti_answer_ok/正确:$ti_answer_ok_num_1/g" $dir_file/tiku_answer_record.txt
				echo -e "$yellow你的答案：$green${answer_if}  答案正确$white"
				sleep 2				
			else
				ti_error=$(grep "错误" $dir_file/tiku_answer_record.txt)
				ti_error_num=$(echo "$ti_error" |awk -F ":" '{print $2}')
				ti_error_num_1=$(expr $ti_error_num + 1)
				sed -i "s/$ti_error/错误:$ti_error_num_1/g" $dir_file/tiku_answer_record.txt

				echo -e "$ti_sort\n你的答案：${answer_if}  答案错误\n此题正确的答案是：${ti_answer}" >>$dir_file/tiku_mistake.txt
				echo -e "$yellow你的答案：$green${answer_if}  $red答案错误$white\n $yellow此题正确的答案是：$green${ti_answer}$white \n错误记录：$dir_file/tiku_mistake.txt"
				sleep 2
			fi
			
			if [ "$tiku_num" == "$tiku_current" ];then
				tiku_correct_num=$(grep "正确" $dir_file/tiku_answer_record.txt | awk -F ":" '{print $2}')
				tiku_error_num=$(grep "错误" $dir_file/tiku_answer_record.txt | awk -F ":" '{print $2}')
				echo ""
				echo -e "$yellow本次考试已经全部结束,当前答对$green${tiku_correct_num}$yellow题，答错$red${tiku_error_num}$yellow题。$white"
				rm -rf $dir_file/tiku_current.txt
				break
			else
				tiku_current=$(($tiku_current + 1 ))
				echo "$tiku_current" > $dir_file/tiku_current.txt
				echo 
			fi
			
		fi
			
	done

}

init() {
	echo "开始恢复初始状态"
	rm -rf $dir_file/tiku_mistake.txt
	rm -rf $dir_file/tiku_answer_record.txt
	rm -rf $dir_file/tiku_current.txt
	echo "恢复完成，重新执行bash dati.sh"
}

sort_tiku(){
	set -x
	rm -rf $dir_file/tiku_sort.txt
	for title_positioncat in `cat $dir_file/tiku.txt | grep -n "[0-9]\. " |awk -F ":" '{print $1}'`
	do
		#计算出标题的所在位置
		title_positioncat_next=$(($title_positioncat + 5))
	
		num="1"
		while [ $num -gt "0" ];do
			sed -n "${title_positioncat},${title_positioncat_next}p" $dir_file/tiku.txt >/tmp/tiku_if.txt
			title_positioncat_if=$(grep "[0-9]\. " /tmp/tiku_if.txt | wc -l)
			
			if [ "$title_positioncat_if" -gt "1" ];then
				title_positioncat_if_num=$(grep "[0-9]\. " /tmp/tiku_if.txt | sed -n "2p")
				title_positioncat_next=$(grep -n "$title_positioncat_if_num" $dir_file/tiku.txt | awk -F ":" '{print $1}')
				title_positioncat_next_1=$(($title_positioncat_next - 1 ))
				sed -n "${title_positioncat},${title_positioncat_next_1}p" $dir_file/tiku.txt >>$dir_file/tiku_sort.txt
				num="0"
			else
				title_positioncat_next=$(($title_positioncat_next +5))
			fi
		done
	
	done
	#还有少量问题。比如最后一段因为没有了，还会继续，要对数量进行限制
}

sort_bian(){
#整理一下编号问题
		#set -x
		for title_positioncat in `cat $dir_file/tiku.txt | grep -n "[0-9]\. " |awk -F ":" '{print $1}'`
		do
			num="1"
			while [ "$tiku_num" -gt "$num" ];do
				init_title=$(sed -n "${title_positioncat}p" $dir_file/tiku.txt)
				revise_title_num=$(sed -n "${title_positioncat}p" $dir_file/tiku.txt |awk -F "\. " '{print $1}')
				revise_title=$(echo $init_title | sed "s/$revise_title_num/$num/g")

				sed -i "s/$init_title/$revise_title/g" $dir_file/tiku.txt
				num=$(($num + 1))
				read a
			done
		done
		
	

}

#插入空行
insert() {
	while [[ "$tiku_num" -gt "$tiku_current" ]];do
		#计算当前题库当前题位置
		set -x
		tiku_current_location=$(cat $dir_file/tiku.txt | grep -n "[0-9]\. " |sed -n "${tiku_current}p" | awk -F ":" '{print $1}')
		sed -i "${tiku_current_location}s/$/\n/" $dir_file/tiku.txt
		#read a
		tiku_current=$(($tiku_current + 1 ))
	done


}


action1="$1"
if [[ -z $action1 ]]; then
	start
else
	case "$action1" in
		insert|init|sort_tiku|sort_bian)
		$action1
		;;
	esac
fi




















