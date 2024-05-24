#
# script to print out tables 
#
foreach f (*.pro)
  echo $f
  cat $f | sed  '/levels/s/levels/lvl/' >! a.jou
  cat a.jou | sed  '/levels/s/levels/lvl/' >! a.jou
  cat a.jou | sed  '/levels/s/levels/lvl/' >! a.jou
  cat a.jou | sed  '/levels/s/levels/lvl/' >! a.jou
  cat a.jou | sed  '/levels/s/levels/lvl/' >! a.jou
#
# multiple files
#  cat $f | sed  '/streplace/s/streplace/strep/' \
# | sed /datatype/s/datatype/ddtype/ >! a.jou
#  cp a.jou $f
end
#\rm a.jou
#
#
