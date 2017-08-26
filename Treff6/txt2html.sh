cat header.html > $1_CppWorldCafe_2017_06_14.html
sed -f sed.$1.txt $1_CppWorldCafe_2017_06_14.txt >> $1_CppWorldCafe_2017_06_14.html
echo "</body></html>" >> $1_CppWorldCafe_2017_06_14.html
