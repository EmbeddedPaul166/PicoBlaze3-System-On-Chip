cd /home/paul/Documents/Laboratory_reports/PUR/PUR_Project/PUR_Project/pBlaze
if { [ catch { xload xmp pBlaze.xmp } result ] } {
  exit 10
}
xset intstyle default
save proj
exit 0
