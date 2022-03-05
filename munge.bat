
mkdir MUNGED

C:\BF2_ModTools\ToolsFL\bin\pc_TextureMunge.exe -inputfile $*.tga  -checkdate -continue -platform PC -sourcedir texture -outputdir MUNGED 

C:\BF2_ModTools\ToolsFL\bin\ScriptMunge.exe -inputfile *.lua   -continue -platform PC -sourcedir  scripts -outputdir MUNGED  

C:\BF2_ModTools\ToolsFL\bin\levelpack.exe -inputfile addme.req -writefiles MUNGED\addme.files -continue -platform PC -sourcedir  req -inputdir MUNGED\ -outputdir . 

move *.log MUNGED 
