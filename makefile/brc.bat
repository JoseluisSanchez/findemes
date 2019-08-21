cd res
copy fdm.rc+manifest.rc findemes.rc
c:\bcc55\bin\brc32 -ic:\bcc55\include;c:\fivetech\fwh1204\include; -r findemes.rc
copy findemes.res ..
cd ..
