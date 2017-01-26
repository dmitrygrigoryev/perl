package DOMAIN;
{
	use strict;
	#constructor
	sub new{
				#init domain with name and boundaries
				my $class = shift;
				my $self = {};
				return bless $self,$class;
			}
	#fast_constructor
	#setters & getters
	#SETTERS
	{sub set_domain_name
			{
				  my ($self,$new_name) = @_;
				 $self->{domain_name} = $new_name;

			}
	sub set_reg3d
			{
				  my ($self,$reg3d) = @_;
				 $self->{reg3d} = $reg3d;				
			}
	sub set_reg2d
			{
				  my ($self,$reg2d) = @_;
				 $self->{reg2d} = $reg2d;				
			}
	#GETTERS
	sub get_domain_name
			{
				  my $self = shift;
				 return $self->{domain_name};

			}
	sub get_reg3d
			{
				  my $self = shift;
				 return $self->{reg3d};

			}
	sub get_reg2d
			{
				  my $self = shift;
				 return $self->{reg2d};

			}}
	#end of setters & getters
	
	#Writing session file based on *.cfx5 file
	sub print_domain_to_file
			{
				my($self,$filename) =@_;
				# print $filename;
				my $domName;
				my $i = 1;
				$domName =$self->{domain_name};
							$domName =~ tr/./_/;
							open SESSION,">>$filename";
							print SESSION	
										"FLOW: Flow Analysis 1
										  DOMAIN:$domName
											Coord Frame = Coord 0
											Domain Type = Fluid
											Location = $self->{reg3d}
											DOMAIN MODELS:
											  BUOYANCY MODEL:
												Option = Non Buoyant
											  END # BUOYANCY MODEL:
											  DOMAIN MOTION:
												Option = Stationary
											  END # DOMAIN MOTION:
											  MESH DEFORMATION:
												Option = None
											  END # MESH DEFORMATION:
											  REFERENCE PRESSURE:
												Reference Pressure = 0 [atm]
											  END # REFERENCE PRESSURE:
											END # DOMAIN MODELS:
											FLUID DEFINITION: Fluid 1
											  Material = Air Ideal Gas
											  Option = Material Library
											  MORPHOLOGY:
												Option = Continuous Fluid
											  END # MORPHOLOGY:
											END # FLUID DEFINITION:Fluid 1
											FLUID MODELS:
											  COMBUSTION MODEL:
												Option = None
											  END # COMBUSTION MODEL:
											  HEAT TRANSFER MODEL:
												Include Viscous Work Term = On
												Option = Total Energy
											  END # HEAT TRANSFER MODEL:
											  THERMAL RADIATION MODEL:
												Option = None
											  END # THERMAL RADIATION MODEL:
											  TURBULENCE MODEL:
												Option = SST
											  END # TURBULENCE MODEL:
											  TURBULENT WALL FUNCTIONS:
													High Speed Model = Off
													Option = Automatic
											  END # TURBULENT WALL FUNCTIONS:
											END # FLUID MODELS:
										  END # DOMAIN:Default Domain
										END # FLOW:Flow Analysis 1
										> update\n";
					close(SESSION);
			}

		#print boundaries
	sub print_boundary_to_file
			{
				my($self,$filename,$dict_hash) = @_;
				my $bn;
				my $expr_name; my $domName;# Safe name for CFX expression
				open SESSION,">>$filename";
				foreach $bn(@{$self->{reg2d}})
				{
					print "Graniza = $bn\n";
					my $increm = 0;
					my $bnd_name;
					my $bnd_type = analize_boundary($bn,$dict_hash);

						$expr_name =  $bn;
						$expr_name =~ tr/_/ /;
						$domName =$self->{domain_name};
						$domName =~ tr/./_/;
						if($bnd_type eq 'Inlet') 
						{
							 # print "$bn eto graniza tipa Inlet\n";
							print SESSION 
										"LIBRARY:
										  CEL:
											EXPRESSIONS:
											  P $expr_name=1e5 [Pa]
											  T $expr_name = 300[K]
											  mf $expr_name = 0.1[kg*s^-1]
											END
										  END
										END
										FLOW: Flow Analysis 1
										  DOMAIN:$domName
											 BOUNDARY: $bn
											  Boundary Type = INLET
											  Interface Boundary = Off
											  Location = $bn
											  BOUNDARY CONDITIONS:
												FLOW DIRECTION:
												  Option = Normal to Boundary Condition
												END # FLOW DIRECTION:
												FLOW REGIME:
												  Option = Subsonic
												END # FLOW REGIME:
												HEAT TRANSFER:
												  Option = Total Temperature
												  Total Temperature = T $expr_name
												END # HEAT TRANSFER:
												MASS AND MOMENTUM:
												  Option = Total Pressure
												  Relative Pressure = P $expr_name
												END # MASS AND MOMENTUM:
												TURBULENCE:
												  Option = Medium Intensity and Eddy Viscosity Ratio
												END # TURBULENCE:
											  END # BOUNDARY CONDITIONS:
											END # BOUNDARY:INLET
										  END # DOMAIN:Default Domain
										END # FLOW:Flow Analysis 1
										> update\n";
						}
						elsif($bnd_type eq 'Outlet')
						{
							# print "$kk eto graniza tipa Outlet\n";
							print SESSION 
										"LIBRARY:
										  CEL:
											EXPRESSIONS:
											  P $expr_name=1e5[Pa]
											  #T $bn = 300[K]
											  mf $expr_name = 0.1[kg*s^-1]
											END
										  END
										END
										FLOW: Flow Analysis 1
										  DOMAIN:$domName
											BOUNDARY: $bn
											  Boundary Type = OUTLET
											  Interface Boundary = Off
											  Location = $bn
											  BOUNDARY CONDITIONS:
												FLOW REGIME:
												  Option = Subsonic
												END # FLOW REGIME:
												MASS AND MOMENTUM:
												  Option = Average Static Pressure
												  Pressure Profile Blend = 0.05
												  Relative Pressure = P $expr_name
												END # MASS AND MOMENTUM:
												PRESSURE AVERAGING:
												  Option = Average Over Whole Outlet
												END # PRESSURE AVERAGING:
											  END # BOUNDARY CONDITIONS:
											END # BOUNDARY:INLET_2 1
										  END # DOMAIN:foil_bearing_5mm_ecc.cfx5
										END # FLOW:Flow Analysis 1
										> update\n"
						}elsif($bnd_type eq 'Wall')
						{
							# print "$kk eto graniza tipa Wall\n";
		
							print SESSION
										"LIBRARY:
										  CEL:
											EXPRESSIONS:
											  Q $expr_name = 1e5[W*m^-2]
											  Tw $expr_name = 300[K]
											  Tf $expr_name = 300[K]
											  Alpha $expr_name = 500[W*m^-1*K^-1]
											END
										  END
										END
										FLOW: Flow Analysis 1
										  DOMAIN:$domName
											&replace     BOUNDARY: $bn
											  Boundary Type = WALL
											  Create Other Side = Off
											  Interface Boundary = Off
											  Location = $bn
											  BOUNDARY CONDITIONS:
												HEAT TRANSFER:
												  Option = Adiabatic
												END # HEAT TRANSFER:
												MASS AND MOMENTUM:
												  Option = No Slip Wall
												END # MASS AND MOMENTUM:
												WALL ROUGHNESS:
												  Option = Smooth Wall
												END # WALL ROUGHNESS:
											  END # BOUNDARY CONDITIONS:
											END # BOUNDARY:WALL
										  END # DOMAIN:foil_bearing_5mm_ecc.cfx5
										END # FLOW:Flow Analysis 1
										> update\n"
						}elsif($bnd_type eq 'Opening')
						{
							# print "$kk eto graniza tipa Opening\n";
							print SESSION 
										"LIBRARY:
										  CEL:
											EXPRESSIONS:
											  P $expr_name=1e5[Pa]
											  T $expr_name = 300[K]
											  mf $expr_name = 0.1[kg*s^-1]
											END
										  END
										END
										FLOW: Flow Analysis 1
										  DOMAIN:$domName
											&replace     BOUNDARY: $bn
											  Boundary Type = OPENING
											  Interface Boundary = Off
											  Location = $bn
											  BOUNDARY CONDITIONS:
												FLOW DIRECTION:
												  Option = Normal to Boundary Condition
												END # FLOW DIRECTION:
												FLOW REGIME:
												  Option = Subsonic
												END # FLOW REGIME:
												HEAT TRANSFER:
												  Opening Temperature = T $expr_name
												  Option = Opening Temperature
												END # HEAT TRANSFER:
												MASS AND MOMENTUM:
												  Option = Opening Pressure and Direction
												  Relative Pressure = P $expr_name
												END # MASS AND MOMENTUM:
												TURBULENCE:
												  Option = Medium Intensity and Eddy Viscosity Ratio
												END # TURBULENCE:
											  END # BOUNDARY CONDITIONS:
											END # BOUNDARY:STAT_WALL
										  END # DOMAIN:meg_disk.cfx5
										END # FLOW:Flow Analysis 1
										>update\n"
						}elsif($bnd_type eq 'Interface')
						{
							# set_interface($prj_dir,$hash_ref,$kk);
						}elsif($bnd_type eq 'Symmetry')
						{
						  print SESSION 
									"FLOW: Flow Analysis 1
									  DOMAIN:$domName
										&replace     BOUNDARY: $bn
										  Boundary Type = SYMMETRY
										  Interface Boundary = Off
										  Location = $bn
										END # BOUNDARY:SYM1
									  END # DOMAIN:meg_disk.cfx5
									END # FLOW:Flow Analysis 1
									> update\n";
						}
				}

				close(SESSION);
			}
	#print Import mesh string to pre-file
	sub print_mesh_to_file
			{
					my ($self,$pre_filename,$prj_dir)  = @_;	
					open SESSION,">>$pre_filename";
					my $mesh_filename = $prj_dir."\\Mesh\\$self->{domain_name}";
					if ($mesh_filename =~ /.+\.cfx5/ )
						{	print SESSION ">gtmImport filename=$mesh_filename, type=Generic, \\\n units=mm,  genOpt= -n, nameStrategy= Assembly\n";}
					#Creating domains
				print SESSION ">update\n";
				close(SESSION);
			}
#Predicate boundary type by boundary name
	sub analize_boundary
			{
				my ($bnd_name,$dict_ref) = @_;
				my $max_leven_metric = 1e8;
				my $med_leven_metric;
				my %dict = %{$dict_ref};
				my $type, my $bnd_type;
					foreach $type(keys %dict)
						{
							# print	"$kk => $dict{$kk}\n";
							my @bnd_vars = split /,/, $dict{$type};
							my $lev_metr = 0;
							foreach my $bnd_var(@bnd_vars)
							{
								if (index(lc($bnd_name),lc($type))>-1)
									{
										print "$bnd_name = $bnd_type";
										 return $type;
									}
									else
									{
										$lev_metr +=levenshtein(lc($bnd_name),lc($bnd_var));
									}
								
								#добавить проверку на полное совпадение расстояние=0
							}
							$med_leven_metric = $lev_metr/($#bnd_vars+1);
							if ($med_leven_metric<$max_leven_metric)
								{
									$max_leven_metric = $med_leven_metric;
									$bnd_type = $type; 
								}
							# print "med_leven_metric = $med_leven_metric from $mesh{$key}[$i] to $kk\n";
						}
				return $bnd_type;		
			}
	#Calculating levenshtein metric
	sub levenshtein 
			{
				my ($w1, $w2, $t) = @_;
				#если слова равны, возвращаем 0
				if($w1 eq $w2) {return 0}
				#я решил сразу разбить слова на массив букв
				my @w1 = split '', $w1;
				my @w2 = split '', $w2;
				#добавляем в начало каждого слова пустой символ
				#это нужно для построения матрицы
				unshift @w1, "";
				unshift @w2, "";
				#вычисляем длину слов.
				#Не использовал функцию length, потому что
				#она может не правильно работать в разных кодировках    
				my ($n, $m) = ($#w1, $#w2);    
				my @d;
				#формируем матрицу, необходимую для рассчета
				$d[$_][0] =$_ for(0..$n);
				$d[0][$_] = $_ for(0..$m);    
				for(my $i=1; $i<=$n; $i++)    {
					for(my $j=1; $j<=$m; $j++)    {
						my $c = ($w1[$i] eq $w2[$j]) ? 0: 1;
						#присваиваем минимальное из трех возможных значений
						$d[$i][$j] = (sort($d[$i-1][$j]+1, $d[$i][$j-1]+1, $d[$i-1][$j-1]+$c))[0];
					}
				}
				return $d[$n][$m];
			}
1;
}
package FUNCTIONS;
{
use Cwd;
use strict;
use File::Spec;
use File::Basename;
#Filling dictionary with typical boundary names
	sub get_script_dir()
		{
			my ($path) = $0=~ /(.*[\/\\])/;	#Определение директории скрипта
			return $path
		}
	sub set_dictionary($)
		{
				 
				# my $path = shift;
				my $dir = dirname(shift);
				chomp($dir);
				chdir($dir);
				print $dir;
				my %dict;
			    open DICT, "dictionary.txt" or die("No dictionary file in script directory $dir");
				# open DICT, "dictionary.txt" or die("No dictionary file in script directory $path");
				while(my $line = <DICT>)
								{
									if ($line=~/^#(.+)/)
									{
										my $line2 = <DICT>;
										$dict{$1} = $line2;
									}
								}
				foreach  my $key(keys(%dict))
					{
						print "$key => ".$dict{$key}."\n";
					}
				return %dict;
		}

#Getting project directory
	sub get_project_dir()
		{
			
			print "Enter project directory\n";
			my $proj_dir = <>;
			# my $proj_dir = 'C:\grigorev_dv\project';
			chomp($proj_dir);
			chdir($proj_dir) or die("There is no directory by $proj_dir path");
			return $proj_dir;
		}
#collect all meshes .cfx5 in Project_dir/Mesh
	sub get_meshes($)
		{
			my $proj_dir =shift;
			my @meshes;
			if( chdir("$proj_dir/Mesh"))
			 {
				opendir prj_dir, getcwd();
				@meshes = grep{/.+\.cfx5/} readdir prj_dir;
			}else
				{
					print "Can't change directory to $proj_dir/Mesh";
				}
				closedir prj_dir;
			return @meshes;
		}
#collect all other meshes in Project_dir/Mesh
	sub get_other_meshes($)
		{
			my $proj_dir =shift;
			my @other_meshes;
			if( chdir("$proj_dir/Mesh"))
			 {
				opendir prj_dir, getcwd();
				@other_meshes = grep{/.+\.gtm|.cgns|.cmdb/} readdir prj_dir;
			}else
				{
					print "Can't change directory to $proj_dir/Mesh";
				}
			closedir prj_dir;
			chdir($proj_dir);
			return @other_meshes;
		}
#creating list of domain objects	
	sub creating_domain_objects
		{
			undef my  @domains;
			my ($meshes_ref) = shift;
			foreach my $mesh(@{$meshes_ref})
				{
						undef my @mkm,my @slice2d,my $dom;
						# print "\n\nmesh  is $mesh\n";
						# my @bnd = get_boundary_names($mesh);
						$dom = DOMAIN -> new();
						$dom -> set_domain_name($mesh);
						my @mkm = get_boundary_names($mesh);
						my @slice2d = @mkm[1..$#mkm];
						 # print "\n 2dBNDS for $mesh";
						 # print join "\n" ,@bnd; 
						# print join "\n",@slice2d;
						$dom -> set_reg3d(@mkm[0]);
						$dom -> set_reg2d(\@slice2d);
						push @domains,$dom;
				}
			return @domains;
		}
#find all named selections in .cfx5 mesh file
	sub get_boundary_names
		{
			my $mesh_name = shift;
				my @bnd;
				my $i = 0;
				open msh_file, "<$mesh_name";
				while (<msh_file>)
				{
					print "Stroka $i\n";
					$i++;
					if($_ =~ /.+\s([a-z_]+[0-9]*)\Z/ismox){
											push @bnd,$1;
										}
				}
				close(msh_file);
			return @bnd;
		}
	
	sub CFX_Root{return $ENV{AWP_Root150}."\\CFX\\bin\\";}
	
	sub start_CFX
	{
		my ($prj_dir,$filename) = @_;
		my $ses = $prj_dir."/slon.pre";
		my @args = (CFX_Root."cfx5pre","-s", $ses);
		print @args;
		system(@args)
	}
	
	
	sub print_header
	{
		my($filename)  = @_;	
		open SESSION,">$filename";
		print SESSION 
			"COMMAND FILE:
				CFX Pre Version = 15.0
			END\n";
		print SESSION 
			">load mode=new\n
			> update\n\n";
		close(SESSION);
	}
	
	sub print_other_meshes
		{
			my $pre_filename = shift;
			my $proj_dir = shift;
			my $mesh_ref = shift;
			my @other_m = @{$mesh_ref};
			my $mesh;
			print join "\n",@other_m;
			open SESSION,">>$pre_filename";
			foreach  $mesh(@other_m)
			{
				my $mesh_filename = $proj_dir."\\Mesh\\$mesh";
				if ($mesh =~ /.+\.gtm/ )
					{
						print SESSION ">gtmImport filename=$mesh_filename, type=GTM, \\\n units=mm, nameStrategy= Assembly\n";
					}elsif($mesh =~ /.+\.cgns/)
						{
							print SESSION "> gtmImport filename=$mesh_filename, type=CGNS, units=m, \\\n genOpt= -n, specOpt= -P -E -c -f -i0, nameStrategy= Assembly"
						}
				
			}
			print SESSION ">update";
			close(SESSION);
		}
		
	sub play_user_sessions
		{
			my $proj_dir = shift;
			my $pre_filename = shift;
			my @sessions;
			my $session;
			if( chdir("$proj_dir/sessions"))
			 {
				opendir prj_dir, getcwd();
				@sessions = grep{/.+\.pre/} readdir prj_dir;
			}else
				{
					print "Can't change directory to $proj_dir/sessions";
				}
			closedir prj_dir;
			open SESSION,">>$pre_filename";
			foreach $session(@sessions)
				{
					my $session_name = $proj_dir."\\session\\$session";
					print SESSION "\n\n>readsession filename=$session_name \n >update\n";
				}
			close(SESSION);
			chdir($proj_dir);
			return 0;
		}
1;
}
package main;
use Cwd;
use strict;
use File::Spec;

print "\n";

#Project directory structure
#
#Структура проекта
#---------------------------------------|
#Project_directory						|
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

#Set project directory
my $path = File::Spec->rel2abs($0);

my $prj_dir = FUNCTIONS::get_project_dir();
FUNCTIONS::print_header($prj_dir."/slon.pre");
#Set dictionary
my %dict = FUNCTIONS::set_dictionary($path);
#Set list of meshes
my @meshes = FUNCTIONS::get_meshes($prj_dir);

my @domains =FUNCTIONS::creating_domain_objects(\@meshes);
foreach my $domain(@domains)
{
	$domain->print_mesh_to_file($prj_dir."/slon.pre",$prj_dir);
	$domain->print_domain_to_file($prj_dir."/slon.pre");
	$domain->print_boundary_to_file($prj_dir."/slon.pre",\%dict);
} 
print "\n\n\n\n";
my @oth_meshes = FUNCTIONS::get_other_meshes($prj_dir);
FUNCTIONS::print_other_meshes($prj_dir."/slon.pre",$prj_dir,\@oth_meshes);
FUNCTIONS::play_user_sessions($prj_dir,$prj_dir."/slon.pre");

FUNCTIONS::start_CFX($prj_dir,0);

