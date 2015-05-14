#!/bin/sh
#
# R pilot script
#
# riccardo.bruno@ct.infn.it
#
#
# Multi-infrastructure job submission needs
# to build some environment variables
#

# SGJP Testing
curl http://jessica.trigrid.it:8660/sgjp 2>/dev/null > sgjp_client.py && python sgjp_client.py 5 "${2}" "${1}" 2>.sgjp.log >.sgjp.log &

#SW_NAME="R-2.13.1"
VO_NAME=$(voms-proxy-info -vo)
VO_VARNAME=$(echo $VO_NAME | sed s/"\."/"_"/g | sed s/"-"/"_"/g | awk '{ print toupper($1) }')
VO_SWPATH_NAME="VO_"$VO_VARNAME"_SW_DIR"
VO_SWPATH_CONTENT=$(echo $VO_SWPATH_NAME | awk '{ cmd=sprintf("echo $%s",$1); system(cmd); }')

echo "Multi infrastructure variables:"
echo "-------------------------------"
echo "VO_NAME          : "$VO_NAME
echo "VO_VARNAME       : "$VO_VARNAME
echo "VO_SWPATH_NAME   : "$VO_SWPATH_NAME
echo "VO_SWPATH_CONTENT: "$VO_SWPATH_CONTENT
echo
#export PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/bin/
case $VO_NAME in
   "prod.vo.eu-eela.eu")
      SW_NAME="R-2.13.1"
      PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/bin/
   ;;
   "eumed")
      SW_NAME="R-2.14.1-1.el5.x86_64"
      PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/usr/bin/
   ;;
   "gridit")
      SW_NAME="R-2.14.1-1.el5.x86_64"
      PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/usr/bin/
   ;;
   *) 
       echo "INFO: VO $VO_NAME not supported"
#       exit 1
esac

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VO_SWPATH_CONTENT/$SW_NAME/lib/octave-3.2.4/
echo "PATH: "$PATH
#echo "LD_LIBRARY_PATH: "$LD_LIBRARY_PATH
echo
echo "Software directory : '"$VO_SWPATH_CONTENT/$SW_NAME"'"
echo "------------------"
ls -ld $VO_SWPATH_CONTENT/$SW_NAME
echo

# Get the hostname
HOSTNAME=$(hostname -f)

# In order to avoid concurrent accesses to files, the 
# portlet uses filename prefixes like
# <timestamp>_<username>_filename
# for this reason the file must be located before to use it
INFILE=$(ls -1 | grep input_file.txt)

echo "--------------------------------------------------"
echo "R job landed on: '"$HOSTNAME"'"
echo "--------------------------------------------------"
echo "Job execution starts on: '"$(date)"'"

echo "---[WN HOME directory]----------------------------"
ls -l $HOME

echo "---[WN Working directory]-------------------------"
ls -l $(pwd)

echo "---[Macro file]---------------------------------"
cat $INFILE
echo

#
# Following statement simulates a produced job file
#
OUTFILE=R_output.txt
echo "--------------------------------------------------"  > $OUTFILE
echo "R job landed on: '"$HOSTNAME"'"                     >> $OUTFILE
echo "infile:  '"$INFILE"'"                               >> $OUTFILE
echo "outfile: '"$OUTFILE"'"                              >> $OUTFILE
echo "--------------------------------------------------" >> $OUTFILE
echo ""                                                   >> $OUTFILE

# Starting R
case $VO_NAME in
   "gridit")
        #$VO_SWPATH_CONTENT/R-2.14.1-1.el5.x86_64/usr/bin/R --vanilla < $INFILE >> $OUTFILE
        $VO_SWPATH_CONTENT/${SW_NAME}/usr/bin/R --vanilla < $INFILE >> $OUTFILE
   ;;
   *) 
	if hash R ; then
	     R --vanilla < $INFILE >> $OUTFILE
	else
	     /usr/local/GARUDA/apps/R-2.15.1/bin/R --vanilla < $INFILE >> $OUTFILE
	fi
esac

# Producing the README.txt file
cat > README.txt << EOF
#
# README.txt
#

This application is able to execute R macros on a distributed infrastructure.
R is a well known tool to generate statistical analisys and eventually plot 
results in a graphical format.
The R macro can be uploaded form the client' PC or directly written into the
text area of the application input form.
If you selected the demo, the example shows how create a bivariate normal 
distribution and how to generate a perspective plot ot the density values.

The output of the application is collected inside a tar.gz archive.
The demo macro will generate a pdf file containing the generated graph.

EOF


#
# At the end of the script file it's a good practice to 
# collect all generated job files into a single tar.gz file
# the generated archive may include the input files as well
#
tar cvfz R-Files.tar.gz ./*



