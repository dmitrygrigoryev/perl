use File::Basename;
@X;
@Y;
@Z;
print "Enter input filename with coordinates(with full path)\n\\>";
$filename = <>;
($nnm,$dir,$ext) = fileparse($filename,('.txt'));
chomp($nnm);
#print $nnm;
$outfile=$dir.$nnm."_out.txt";
print $outfile."\n";
open(a,"<$filename") or die;
open(out,">$outfile");
while($line=<a>)
{
	if ($line=~/([`X`|`Y`|`Z`])+\s=(\D+\d.+)\s/)
	{
		if ($1 eq "X")
		{
			push(@X,$2);
		}elsif($1 eq "Y")
		{
			push(@Y,$2);
		}else
		{
			push(@Z,$2);
		}
		
	}
}
print $#X;
for (my $i=0;$i<=$#X;$i++)
{
	$j=$i+1;
	print out "@X[$i] @Y[$i] @Z[$i]\n"
	
	#print out "1 $j @X[$i] @Y[$i] @Z[$i]\n"
}
	#print out join("\n",@X);#объединяет массив в строку с разделителем "перевод каретки"
#?print "Output file created succesfully":print "Output file did not created"; compact if else
close(a);
close(out);