package num_diff;
use Exporter;
#use Benchmark;
@ISA = ('Exporter');
@EXPORT = qw(&num_diff,&FindRootBis,&FindRootInterval,&FindRootSec);
#$t0 = Benchmark->new;
# sub sqr($)
# {
	# my $x = @_[0];
	# return $x**3;
# }
sub num_diff($$$;$$)
{
#порядок аргументов: левая граница,правая граница
#ссылка на функцию, шаг(опционально),ссылка на параметры ф-ии(опционально)
	my ($Xmin,$Xmax,$func_ref) = @_;
	my $h;
	if (@_[3])
			{
				$h = @_[3];
			}else
				{
					$h = 1E-4;
				}
	my $n = ($Xmax-$Xmin)/$h;
	my $x0,$x1,$y0,$y1;
	if ($n>=1)
			{
				print "Shag diff=$h\n";
				$x0 = $Xmin;
				for(my $i=0;$i<$n;$i++)
									{
										$y0 = ($func_ref)->($x0);
										$x1 = $x0+$h;
										$y1 = ($func_ref)->($x1);
										$dydx = ($y1-$y0)/$h;
										push(@dy,$dydx);
										$x0 = $x1;
									}
			}else
				{
					print "Slishcom malen'kiy shag\n";
					$h =($Xmax-$Xmin)/500;
					print "Prinyat shag=$h\n";
					num_diff($Xmin,$Xmax,$func_ref,$h);
				}
	return @dy;
}
# open(a,">X:\\test1.txt");
# @res = num_diff(0,100,\&sqr,0.00001);#kolichestvo otrezkov z
# print a join("\n",@res);
# close(a);
# $t1 = Benchmark->new;
# $tt = timediff($t1,$t0);
# print "\n";
# print timestr($tt);
# print "\n";
sub FindRootBis($$$;@)
{
#Функция нахождения нуля ф-ии методом бисекции отрезка
#Входные параметры: границы отрезка, ссылка на функцию,
#вектор параметров для ф-ии
{	my ($Xmin,$Xmax,$funcRef,@Params) = @_;
	my $Xmean = ($Xmax+$Xmin)/2;
		while (($Xmax-$Xmin)>=0.000001)
									{
										$out = $Xmean;
										#print "$out\n";
										$tmp1 = ($funcRef)->($Xmin,@Params);
										$out = $tmp1;
										#print "$out\n";
										$tmp2 = ($funcRef)->($Xmean,@Params);
										$tmp3 = ($funcRef)->($Xmax,@Params);
										$out = $tmp2;
										#print "$out\n";
										if(($tmp1)*($tmp2)<=0)
															{
																#($funcRef)->($x,@ll) разыменование ссылки на функцию
																$Xmax = $Xmean;
															}else
																{
																	$Xmin = $Xmean;
																}
									
										$Xmean = ($Xmax+$Xmin)/2;$Xmean = ($Xmax+$Xmin)/2;
									}
	return $Xmean;	
}
}

sub FindRootSec($$$;@)
{
#Функция нахождения нуля ф-ии методом секущих
#Входные параметры: начальные приближения, ссылка на функцию,
#вектор параметров для ф-ии
	my ($Xn0,$Xn1,$funcRef,@Params) = @_;
	my $Xn2;
	while(abs(($funcRef)->($Xn1,@Params))>0.00001)
												{
													$fx0 = ($funcRef)->($Xn0,@Params);
													$fx1 = ($funcRef)->($Xn1,@Params);
													$Xn2 = $Xn1 - (($Xn1-$Xn0)*$fx1)/($fx1-$fx0);
													$Xn0 = $Xn1;
													$Xn1 = $Xn2;
													#print $Xn2;
												}
	return $Xn2;
}

sub FindRootInterval($$$;@)
{
#Находит интервалы локализации корней
#было бы неплохо переписать на потоки
	my ($Xmin,$Xmax,$funcRef,@Params) = @_;
	$scale = 2;
	my $n = 500;
	my $eps = 1E-8;
	my $h = ($Xmax-$Xmin)/$n;
	my $fx1,$fx2;
	#print "$h\n";
	my $x1,$x2;
	$x2 = $Xmin;
	#open(a,">X:\\test1.txt");
	for (my $i=0;$i<$n;$i++)
		{
			$x1 = $Xmin+$h;
			$fx1 = ($funcRef)->($Xmin,@Params);
			$fx2 = ($funcRef)->($x1,@Params);
			if (($fx1*$fx2)<=$eps)
							{
								#print "Otrezok ot $Xmin do $x1 sodergit koren\n";
								push(@res,[$Xmin,$x1]);
							}else
								{
									#print a "Otrezok ot $Xmin do $x1\n";
								}
			$Xmin = $x1;
		}
		#print "dlina massive res = $#res+1\n";
		if (($#res+1)>0)
			{
				return @res;
			}else
				{
					print "Utochnite interval poiska\n";
				}
		if(abs($x2*$scale)<1E10){
									FindRootInterval($x2*$scale,$Xmax*$scale,$funcRef,@Params);
								}else
									{
										print "Nu ochen' neudachnoe pribligenie.\nPoprobuite simmetrichnoe otnositel\'no nachala coord."
									}
			
}

sub Polinom($;@)
{
#Функция вычисляющая значение полинома n-й степени
#Входные параметры: значение X, вектор коэффициентов полинома 
	my($x,@coefs) = @_;
	my $sum=0;
	for($i=0,$j=$#coefs;$i<=$#coefs;$i++,$j--)
											{
												 $sum +=@coefs[$i]*($x**($j));
												 #print "$j\n";
												 #print "@coefs[$i]".'*'.$x.'^'.($j)."\n"
											}
	return $sum;
}
1;