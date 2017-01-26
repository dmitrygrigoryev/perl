package main;
#use strict;
use Cwd;

	sub CFX_Root{return $ENV{AWP_Root150}."\\CFX\\bin\\";};
	
	# sub get_project_dir()
		# {#Получаем директорию проекта
			
			# print "Enter project directory\n";
			# # my $project_dir = <>;
			# my $project_dir = 'C:/grigorev_dv/test/';
			# chomp($project_dir);
			# chdir($project_dir);
			# return $project_dir;
		# };
	
	sub get_ccls($)
		{#Ищем все .ccl файлы в директории $project_dir/ccls	
			my $project_dir =shift;
			my @ccls;
			if( chdir("$project_dir/ccls"))
			 {
				opendir project_dir, getcwd();
				@ccls = grep{/.+\.ccl/} readdir project_dir;
			}else
				{
					print "ERRORR!!!!";
				}
			return @ccls;
		}
	sub get_def($)
		{# Ищем .def в $project_dir
			my @defs;
			my $project_dir = shift;
			opendir project_dir, $project_dir;
			@defs = grep{/.+\.def/} readdir project_dir;
			my $full_path_def = $project_dir."\\"."$defs[0]\n";
			if ($#defs+1>0){
							return $full_path_def;
							}else
								{return -1; }
		}
	sub start_CFX_solver
		{#Запускаем солвер в цикле по *.ccl файлам  
			my ($project_dir,$def_name,$ccls_ref) = @_;
			my @ccls = @{$ccls_ref};
			@timestamp = localtime;
			open SOLVER_LOG,">>C:\\Temp\\solver_log.txt";
			print SOLVER_LOG join ":",@timestamp;
			if ($#ccls+1>0){
							foreach $ccl(@ccls)
									{
										$ccl_full = "$project_dir\\ccls\\".$ccl;
										print $ccl_full."\n";
										print $def_name."\n";
										chomp($def_name);
										my @args = (CFX_Root."cfx5solve.exe","-pri", "Low","-def",$def_name,"-ccl",$ccl_full,"-chdir",$project_dir,"-fullname","$ccl");
										print SOLVER_LOG @args;
										print SOLVER_LOG "\n";
										print @args;
										print "\n";
										 $res = system(@args);
										if ($res==0){
											print "CFX Solver run finished for $def_name with $ccl_full params without errors\n"; 
											print SOLVER_LOG "CFX Solver run finished for $def_name with $ccl_full params without errors\n"; 
											}else{
													print "CFX Solver run finished with exit code $res\n";
													print SOLVER_LOG "CFX Solver run finished with exit code $res\n";
												}
									}
						  }else{
									print "Can't start CFX solver for $project_dir project directory[no .CCL files in $project_dir/ccls]\n";
									print SOLVER_LOG "Can't start CFX solver for $project_dir project directory[no .CCL files in $project_dir/ccls]\n";
									return -1;
								}
			close(SOLVER_LOG);
			return 0;
		};		
sub check_Licences
		{##проверка количества доступных лицензий для приложений
			$lic_name = shift;
			open TEST, ">C:\\Temp\\lic.txt";
			close(TEST);
			my @lines1 = 0;
			# @args = ("C:\\Program Files\\ANSYS Inc\\Shared Files\\Licensing\\winx64\\ansysli_util.exe","-log", "C:\\Temp\\lic.txt","-printavail");
			# @args1 = ("C:\\Program Files\\ANSYS Inc\\Shared Files\\Licensing\\winx64\\ansysli_util.exe","-printavail");
			 # system(@args1);
			 # system("cls");
			 $ans_root = $ENV{AWP_Root150};
			@lines1 = `"C:\\Program Files\\ANSYS Inc\\Shared Files\\Licensing\\winx64\\ansysli_util.exe" -printavail"`;
			my %license;
			$#license = ();
			my $i;
			# %tmp_hash = ();
			#Выковыриваем нужные поля из всех записей о лицензиях
			for ($i=0;$i<$#lines1+1;$i++)
				{
					if($lines1[$i] !~ /Feature:/)
					{
						 # print $lines[$i];
						if ($lines1[$i] =~ /(\bNAME|COUNT|USED):(.+)\Z/ )
							{
							# print "111"."\n";
								# $tmp_hash{$1} = $2;
								push @new, $lines1[$i];
							}
					}
				}
				# print @new;
				#Выковыриваем количество лицензий в наличии и занятых
				print "NEW = ".$#new;
			for($i=0;$i<$#new-1;$i++)
				{
					if ($new[$i] =~ /NAME:\s+(.+)/)
						{
							open TEST, ">C:\\Temp\\lic.txt";
								print TEST $1."\n";
							close(TEST);		
							
							($par1,$val1) = split /:/,$new[$i+1];
							($par2,$val2) = split /:/,$new[$i+2];
							if ($license{$1})
								{
									$license{$1}{COUNT} += $val1;
								}else
								{
									$license{$1}{COUNT} = $val1;
									$license{$1}{USED} = $val2;
								}
							}
				}
				print $license{acfd}{USED};
				$delta = 0;
				@new = 0;
				$delta = $license{$lic_name}{COUNT} - $license{$lic_name}{USED};
				$license{$lic_name}{COUNT} = 0;
				$license{$lic_name}{USED} = 0;
				print "delta = $delta\n";
				#Если есть ли
				if ($delta>0) {return 1}else{return 0};
		}
#Project directory structure
#
#Структура проекта
#---------------------------------------|
#Project_dir							|
#	|									|
#	|----Mesh                           |
#	|		|--mesh1.cfx5               |
#	|		|--mesh2.cfx5               |
#	|----ccls                           |
#	|	 	|--variant1.ccl             |
#	|		|--variant2.ccl             |
#	|                                   |
#	|----project1.def	                |
#                                       |
#---------------------------------------|


#------------------------------------------------------------------------------------------------------------------|
#																												   |
#		Основная логика запуска																					   |
#																												   |
#------------------------------------------------------------------------------------------------------------------|


#-----------------------------|
#	Открываем книгу проектов  |
#-----------------------------|
print "Enter path to file with projects directory list:\n";
my $filename = <>;
open LOG,">C:\\Temp\\task_starter_log.txt";
print localtime(time());
#Получаем список директорий проектов
open PROJECTS, $filename;
@project_dirs = <PROJECTS>;
close(PROJECTS);
#Выполняем все проекты по списку директорий
foreach $project_dir(@project_dirs)
	{
		chomp($project_dir);
		my $res;
		my $def_name = get_def($project_dir) ;
		if ($def_name != -1)
					{
						print $def_name."\n";
						my @proj_ccls = get_ccls($project_dir);
						#Запускаем цикл захвата лицензии
						my $fl = 0;
						while (not($fl))
						{
							if (check_Licences('acfd'))
							{
								print "1 acfd license taken for $project_dir project\n\n";
								print LOG "1 acfd license taken for $project_dir project\n\n";
								  $res = start_CFX_solver($project_dir,$def_name,\@proj_ccls);
								#Лицензия захвачена рептилоидами с планеты Нубиру. Вертим флаг обратно.
								$fl = 1;
								#Пишем в лог историю
								if ($res == 0)
									{
										print LOG "All solver processes passed. Solver messages in solver_log file.";
									}else
										{
											print LOG "Solver can't start. Solver messages in solver_log file."
										}
								
							}else
								{
									#Тактическое отступление. Ожидаем 1 мин, чтобы на серваке не забанили.
									$timeout = 1*60;
									print "All licences in use. Sleep $timeout seconds\n";
									print LOG "All licences in use. Sleep $timeout seconds\n";
									sleep $timeout;
								}						
						}

					}else
						{print  "No .def file in $project_dir directory";
						 print LOG "No .def file in $project_dir directory";}

}
close(LOG);
