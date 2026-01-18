#!/bin/bash
# set -x
mkdir ip
conntrack -L -p udp -f ipv4 | grep ASSURED  > 1
conntrack -L -p udp -f ipv6 | grep ASSURED > 1v6
cat 1 | awk '{ print $4 }' | awk -F= '{ print $2 }' | sort -u | sed 's/\.[0-9]*$/.0/' > 2
cat 1v6 | awk '{ print $5 }' | awk -F= '{ print $2 }' | sort -u | awk '{if(NF<8){inner = "0"; for(missing = (8 - NF);missing>0;--missing){inner = inner ":0"}; if($2 == ""){$2 = inner} else if($3 == ""){$3 = inner} else if($4 == ""){$4 = inner} else if($5 == ""){$5 = inner} else if($6 == ""){$6 = inner} else if($7 == ""){$7 = inner}}; print $0}' FS=":" OFS=":" | awk '{for(i=1;i<9;++i){len = length($(i)); if(len < 1){$(i) = "0000"} else if(len < 2){$(i) = "000" $(i)} else if(len < 3){$(i) = "00" $(i)} else if(len < 4){$(i) = "0" $(i)} }; print $0}' FS=":" OFS=":" | grep -o ^....:....: | sed 's/:$/::/' >> 2
Linenum=`wc -l < 2`
if [ "$Linenum" -lt 5396 ];
then
split -l 99 -d 2 ip/3
else
echo  "The file is too large."
/bin/rm -r -f 1
/bin/rm -r ip 1v6
exit;
fi
for i in `ls ip`;
do
xargs -a ip/$i | sed 's/ /", "/g' | sed "s/.*/\'\[\"&\"\]\'/" > 2-$i
file=$(cat 2-$i)
echo "curl -s http://ip-api.com/batch?fields=1 --data $file | xargs | tr , '\n' >> 3" | bash -
done;
echo "####"
cat 3 | sed 's/{country://g' | sed 's/}//;s/{//g' | sed 's/]//g' | sed 's/\[//g' | sort | uniq -c | sort -r
echo "####"
/bin/rm -r -f iv6 1 2 3 2-30*
/bin/rm -r ip
