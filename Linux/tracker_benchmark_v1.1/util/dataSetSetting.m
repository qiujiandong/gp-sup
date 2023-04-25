dataSet = 'OTB100';
% dataSet = 'UAV123';

% Linux
% parent_loc = '/home/ubuntu/gp-sup/Linux'; % no slash at the end!

% Windows
parent_loc = 'D:/gp-sup/Linux'; % no slash at the end!

if strcmp(dataSet, 'OTB100')
    rpAll = './results/OTB100_results_OPE/'; % result path
    pathDraw = './tmp/OTB100_imgs/';% The folder that will stores the images with overlaid bounding box
    attPath = './anno_OTB100/att/'; % The folder that contains the annotation files for sequence attributes
    pathAnno = './anno_OTB100/';
    attName={'illumination variation' 'scale variation' 'occlusion' 'deformation' 'motion blur' 'fast motion' 'in-plane rotation' 'out-of-plane rotation' 'out of view' 'background clutter' 'low resolution'};
    attFigName={'IV' 'OPR' 'SV' 'OCC' 'DEF' 'MB' 'FM' 'IPR' 'OV' 'BC' 'LR'};
    figPath = './figs/OTB100_overall/';
    perfMatPath = './perfMat/OTB100_overall/';
    seqs = { ...
        struct('name','Basketball','path',[parent_loc '/data_seq/OTB100/Basketball/img/'],'startFrame',1,'endFrame',725,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Biker','path',[parent_loc '/data_seq/OTB100/Biker/img/'],'startFrame',1,'endFrame',142,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Bird1','path',[parent_loc '/data_seq/OTB100/Bird1/img/'],'startFrame',1,'endFrame',408,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Bird2','path',[parent_loc '/data_seq/OTB100/Bird2/img/'],'startFrame',1,'endFrame',99,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','BlurBody','path',[parent_loc '/data_seq/OTB100/BlurBody/img/'],'startFrame',1,'endFrame',334,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','BlurCar1','path',[parent_loc '/data_seq/OTB100/BlurCar1/img/'],'startFrame',247,'endFrame',988,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','BlurCar2','path',[parent_loc '/data_seq/OTB100/BlurCar2/img/'],'startFrame',1,'endFrame',585,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','BlurCar3','path',[parent_loc '/data_seq/OTB100/BlurCar3/img/'],'startFrame',3,'endFrame',359,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','BlurCar4','path',[parent_loc '/data_seq/OTB100/BlurCar4/img/'],'startFrame',18,'endFrame',397,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','BlurFace','path',[parent_loc '/data_seq/OTB100/BlurFace/img/'],'startFrame',1,'endFrame',493,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','BlurOwl','path',[parent_loc '/data_seq/OTB100/BlurOwl/img/'],'startFrame',1,'endFrame',631,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Board','path',[parent_loc '/data_seq/OTB100/Board/img/'],'startFrame',1,'endFrame',698,'nz',5,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Bolt','path',[parent_loc '/data_seq/OTB100/Bolt/img/'],'startFrame',1,'endFrame',350,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Bolt2','path',[parent_loc '/data_seq/OTB100/Bolt2/img/'],'startFrame',1,'endFrame',293,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Box','path',[parent_loc '/data_seq/OTB100/Box/img/'],'startFrame',1,'endFrame',1161,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Boy','path',[parent_loc '/data_seq/OTB100/Boy/img/'],'startFrame',1,'endFrame',602,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Car1','path',[parent_loc '/data_seq/OTB100/Car1/img/'],'startFrame',1,'endFrame',1020,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Car2','path',[parent_loc '/data_seq/OTB100/Car2/img/'],'startFrame',1,'endFrame',913,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Car4','path',[parent_loc '/data_seq/OTB100/Car4/img/'],'startFrame',1,'endFrame',659,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Car24','path',[parent_loc '/data_seq/OTB100/Car24/img/'],'startFrame',1,'endFrame',3059,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','CarDark','path',[parent_loc '/data_seq/OTB100/CarDark/img/'],'startFrame',1,'endFrame',393,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','CarScale','path',[parent_loc '/data_seq/OTB100/CarScale/img/'],'startFrame',1,'endFrame',252,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','ClifBar','path',[parent_loc '/data_seq/OTB100/ClifBar/img/'],'startFrame',1,'endFrame',472,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Coke','path',[parent_loc '/data_seq/OTB100/Coke/img/'],'startFrame',1,'endFrame',291,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Couple','path',[parent_loc '/data_seq/OTB100/Couple/img/'],'startFrame',1,'endFrame',140,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Coupon','path',[parent_loc '/data_seq/OTB100/Coupon/img/'],'startFrame',1,'endFrame',327,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Crossing','path',[parent_loc '/data_seq/OTB100/Crossing/img/'],'startFrame',1,'endFrame',120,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Crowds','path',[parent_loc '/data_seq/OTB100/Crowds/img/'],'startFrame',1,'endFrame',347,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Dancer','path',[parent_loc '/data_seq/OTB100/Dancer/img/'],'startFrame',1,'endFrame',225,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Dancer2','path',[parent_loc '/data_seq/OTB100/Dancer2/img/'],'startFrame',1,'endFrame',150,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','David','path',[parent_loc '/data_seq/OTB100/David/img/'],'startFrame',300,'endFrame',770,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','David2','path',[parent_loc '/data_seq/OTB100/David2/img/'],'startFrame',1,'endFrame',537,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','David3','path',[parent_loc '/data_seq/OTB100/David3/img/'],'startFrame',1,'endFrame',252,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Deer','path',[parent_loc '/data_seq/OTB100/Deer/img/'],'startFrame',1,'endFrame',71,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Diving','path',[parent_loc '/data_seq/OTB100/Diving/img/'],'startFrame',1,'endFrame',215,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Dog','path',[parent_loc '/data_seq/OTB100/Dog/img/'],'startFrame',1,'endFrame',127,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Dog1','path',[parent_loc '/data_seq/OTB100/Dog1/img/'],'startFrame',1,'endFrame',1350,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Doll','path',[parent_loc '/data_seq/OTB100/Doll/img/'],'startFrame',1,'endFrame',3872,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','DragonBaby','path',[parent_loc '/data_seq/OTB100/DragonBaby/img/'],'startFrame',1,'endFrame',113,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Dudek','path',[parent_loc '/data_seq/OTB100/Dudek/img/'],'startFrame',1,'endFrame',1145,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Faceocc1','path',[parent_loc '/data_seq/OTB100/Faceocc1/img/'],'startFrame',1,'endFrame',892,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Faceocc2','path',[parent_loc '/data_seq/OTB100/Faceocc2/img/'],'startFrame',1,'endFrame',812,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Fish','path',[parent_loc '/data_seq/OTB100/Fish/img/'],'startFrame',1,'endFrame',476,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Fleetface','path',[parent_loc '/data_seq/OTB100/Fleetface/img/'],'startFrame',1,'endFrame',707,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Football','path',[parent_loc '/data_seq/OTB100/Football/img/'],'startFrame',1,'endFrame',362,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Football1','path',[parent_loc '/data_seq/OTB100/Football1/img/'],'startFrame',1,'endFrame',74,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Freeman1','path',[parent_loc '/data_seq/OTB100/Freeman1/img/'],'startFrame',1,'endFrame',326,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Freeman3','path',[parent_loc '/data_seq/OTB100/Freeman3/img/'],'startFrame',1,'endFrame',460,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Freeman4','path',[parent_loc '/data_seq/OTB100/Freeman4/img/'],'startFrame',1,'endFrame',283,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Girl','path',[parent_loc '/data_seq/OTB100/Girl/img/'],'startFrame',1,'endFrame',500,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Girl2','path',[parent_loc '/data_seq/OTB100/Girl2/img/'],'startFrame',1,'endFrame',1500,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Gym','path',[parent_loc '/data_seq/OTB100/Gym/img/'],'startFrame',1,'endFrame',767,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human2','path',[parent_loc '/data_seq/OTB100/Human2/img/'],'startFrame',1,'endFrame',1128,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human3','path',[parent_loc '/data_seq/OTB100/Human3/img/'],'startFrame',1,'endFrame',1698,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human4.2','path',[parent_loc '/data_seq/OTB100/Human4/img/'],'startFrame',1,'endFrame',667,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human5','path',[parent_loc '/data_seq/OTB100/Human5/img/'],'startFrame',1,'endFrame',713,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human6','path',[parent_loc '/data_seq/OTB100/Human6/img/'],'startFrame',1,'endFrame',792,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human7','path',[parent_loc '/data_seq/OTB100/Human7/img/'],'startFrame',1,'endFrame',250,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human8','path',[parent_loc '/data_seq/OTB100/Human8/img/'],'startFrame',1,'endFrame',128,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Human9','path',[parent_loc '/data_seq/OTB100/Human9/img/'],'startFrame',1,'endFrame',305,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Ironman','path',[parent_loc '/data_seq/OTB100/Ironman/img/'],'startFrame',1,'endFrame',166,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Jogging.1','path',[parent_loc '/data_seq/OTB100/Jogging/img/'],'startFrame',1,'endFrame',307,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Jogging.2','path',[parent_loc '/data_seq/OTB100/Jogging/img/'],'startFrame',1,'endFrame',307,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Jump','path',[parent_loc '/data_seq/OTB100/Jump/img/'],'startFrame',1,'endFrame',122,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Jumping','path',[parent_loc '/data_seq/OTB100/Jumping/img/'],'startFrame',1,'endFrame',313,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','KiteSurf','path',[parent_loc '/data_seq/OTB100/KiteSurf/img/'],'startFrame',1,'endFrame',84,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Lemming','path',[parent_loc '/data_seq/OTB100/Lemming/img/'],'startFrame',1,'endFrame',1336,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Liquor','path',[parent_loc '/data_seq/OTB100/Liquor/img/'],'startFrame',1,'endFrame',1741,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Man','path',[parent_loc '/data_seq/OTB100/Man/img/'],'startFrame',1,'endFrame',134,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Matrix','path',[parent_loc '/data_seq/OTB100/Matrix/img/'],'startFrame',1,'endFrame',100,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Mhyang','path',[parent_loc '/data_seq/OTB100/Mhyang/img/'],'startFrame',1,'endFrame',1490,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','MotorRolling','path',[parent_loc '/data_seq/OTB100/MotorRolling/img/'],'startFrame',1,'endFrame',164,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','MountainBike','path',[parent_loc '/data_seq/OTB100/MountainBike/img/'],'startFrame',1,'endFrame',228,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Panda','path',[parent_loc '/data_seq/OTB100/Panda/img/'],'startFrame',1,'endFrame',1000,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','RedTeam','path',[parent_loc '/data_seq/OTB100/RedTeam/img/'],'startFrame',1,'endFrame',1918,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Rubik','path',[parent_loc '/data_seq/OTB100/Rubik/img/'],'startFrame',1,'endFrame',1997,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Shaking','path',[parent_loc '/data_seq/OTB100/Shaking/img/'],'startFrame',1,'endFrame',365,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Singer1','path',[parent_loc '/data_seq/OTB100/Singer1/img/'],'startFrame',1,'endFrame',351,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Singer2','path',[parent_loc '/data_seq/OTB100/Singer2/img/'],'startFrame',1,'endFrame',366,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Skater','path',[parent_loc '/data_seq/OTB100/Skater/img/'],'startFrame',1,'endFrame',160,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Skater2','path',[parent_loc '/data_seq/OTB100/Skater2/img/'],'startFrame',1,'endFrame',435,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Skating1','path',[parent_loc '/data_seq/OTB100/Skating1/img/'],'startFrame',1,'endFrame',400,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Skating2.1','path',[parent_loc '/data_seq/OTB100/Skating2/img/'],'startFrame',1,'endFrame',473,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Skating2.2','path',[parent_loc '/data_seq/OTB100/Skating2/img/'],'startFrame',1,'endFrame',473,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Skiing','path',[parent_loc '/data_seq/OTB100/Skiing/img/'],'startFrame',1,'endFrame',81,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Soccer','path',[parent_loc '/data_seq/OTB100/Soccer/img/'],'startFrame',1,'endFrame',392,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Subway','path',[parent_loc '/data_seq/OTB100/Subway/img/'],'startFrame',1,'endFrame',175,'nz',4,'ext','jpg','init_rect', [0 0 0 0]),... 
        struct('name','Surfer','path',[parent_loc '/data_seq/OTB100/Surfer/img/'],'startFrame',1,'endFrame',376,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Suv','path',[parent_loc '/data_seq/OTB100/Suv/img/'],'startFrame',1,'endFrame',945,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Sylvester','path',[parent_loc '/data_seq/OTB100/Sylvester/img/'],'startFrame',1,'endFrame',1345,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Tiger1','path',[parent_loc '/data_seq/OTB100/Tiger1/img/'],'startFrame',1,'endFrame',354,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Tiger2','path',[parent_loc '/data_seq/OTB100/Tiger2/img/'],'startFrame',1,'endFrame',365,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Toy','path',[parent_loc '/data_seq/OTB100/Toy/img/'],'startFrame',1,'endFrame',271,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Trans','path',[parent_loc '/data_seq/OTB100/Trans/img/'],'startFrame',1,'endFrame',124,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Trellis','path',[parent_loc '/data_seq/OTB100/Trellis/img/'],'startFrame',1,'endFrame',569,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Twinnings','path',[parent_loc '/data_seq/OTB100/Twinnings/img/'],'startFrame',1,'endFrame',472,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Vase','path',[parent_loc '/data_seq/OTB100/Vase/img/'],'startFrame',1,'endFrame',271,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Walking','path',[parent_loc '/data_seq/OTB100/Walking/img/'],'startFrame',1,'endFrame',412,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Walking2','path',[parent_loc '/data_seq/OTB100/Walking2/img/'],'startFrame',1,'endFrame',500,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','Woman','path',[parent_loc '/data_seq/OTB100/Woman/img/'],'startFrame',1,'endFrame',597,'nz',4,'ext','jpg','init_rect', [0,0,0,0]),...
    };
elseif strcmp(dataSet, 'UAV123')
    rpAll = './results/UAV123_results_OPE/'; % result path
    pathDraw = './tmp/UAV123_imgs/';% The folder that will stores the images with overlaid bounding box
    attPath = './anno_UAV123/att/'; % The folder that contains the annotation files for sequence attributes
    pathAnno = './anno_UAV123/';
    attName={'Scale Variation' 'Aspect Ratio Change' 'Low Resolution' 'Fast Motion' 'Full Occlusion' 'Partial Occlusion' 'Out-of-View' 'Background Clutter' 'Illumination Variation' 'Viewpoint Change' 'Camera Motion' 'Similar Object'};
    attFigName={'SV'	'ARC'	'LR'	'FM'	'FOC'	'POC'	'OV'	'BC'	'IV'	'VC'	'CM'	'SOB'};
    figPath = './figs/UAV123_overall/';
    perfMatPath = './perfMat/UAV123_overall/';
    seqs = {
        struct('name','bike1','path',[parent_loc '/data_seq/UAV123/bike1/'],'startFrame',1,'endFrame',3085,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','bike2','path',[parent_loc '/data_seq/UAV123/bike2/'],'startFrame',1,'endFrame',553,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','bike3','path',[parent_loc '/data_seq/UAV123/bike3/'],'startFrame',1,'endFrame',433,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','bird1_1','path',[parent_loc '/data_seq/UAV123/bird1/'],'startFrame',1,'endFrame',253,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','bird1_2','path',[parent_loc '/data_seq/UAV123/bird1/'],'startFrame',775,'endFrame',1477,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','bird1_3','path',[parent_loc '/data_seq/UAV123/bird1/'],'startFrame',1573,'endFrame',2437,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat1','path',[parent_loc '/data_seq/UAV123/boat1/'],'startFrame',1,'endFrame',901,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat2','path',[parent_loc '/data_seq/UAV123/boat2/'],'startFrame',1,'endFrame',799,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat3','path',[parent_loc '/data_seq/UAV123/boat3/'],'startFrame',1,'endFrame',901,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat4','path',[parent_loc '/data_seq/UAV123/boat4/'],'startFrame',1,'endFrame',553,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat5','path',[parent_loc '/data_seq/UAV123/boat5/'],'startFrame',1,'endFrame',505,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat6','path',[parent_loc '/data_seq/UAV123/boat6/'],'startFrame',1,'endFrame',805,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat7','path',[parent_loc '/data_seq/UAV123/boat7/'],'startFrame',1,'endFrame',535,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat8','path',[parent_loc '/data_seq/UAV123/boat8/'],'startFrame',1,'endFrame',685,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','boat9','path',[parent_loc '/data_seq/UAV123/boat9/'],'startFrame',1,'endFrame',1399,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','building1','path',[parent_loc '/data_seq/UAV123/building1/'],'startFrame',1,'endFrame',469,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','building2','path',[parent_loc '/data_seq/UAV123/building2/'],'startFrame',1,'endFrame',577,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','building3','path',[parent_loc '/data_seq/UAV123/building3/'],'startFrame',1,'endFrame',829,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','building4','path',[parent_loc '/data_seq/UAV123/building4/'],'startFrame',1,'endFrame',787,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','building5','path',[parent_loc '/data_seq/UAV123/building5/'],'startFrame',1,'endFrame',481,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car1_1','path',[parent_loc '/data_seq/UAV123/car1/'],'startFrame',1,'endFrame',751,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car1_2','path',[parent_loc '/data_seq/UAV123/car1/'],'startFrame',751,'endFrame',1627,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car1_3','path',[parent_loc '/data_seq/UAV123/car1/'],'startFrame',1627,'endFrame',2629,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car2','path',[parent_loc '/data_seq/UAV123/car2/'],'startFrame',1,'endFrame',1321,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car3','path',[parent_loc '/data_seq/UAV123/car3/'],'startFrame',1,'endFrame',1717,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car4','path',[parent_loc '/data_seq/UAV123/car4/'],'startFrame',1,'endFrame',1345,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car5','path',[parent_loc '/data_seq/UAV123/car5/'],'startFrame',1,'endFrame',745,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car6_1','path',[parent_loc '/data_seq/UAV123/car6/'],'startFrame',1,'endFrame',487,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car6_2','path',[parent_loc '/data_seq/UAV123/car6/'],'startFrame',487,'endFrame',1807,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car6_3','path',[parent_loc '/data_seq/UAV123/car6/'],'startFrame',1807,'endFrame',2953,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car6_4','path',[parent_loc '/data_seq/UAV123/car6/'],'startFrame',2953,'endFrame',3925,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car6_5','path',[parent_loc '/data_seq/UAV123/car6/'],'startFrame',3925,'endFrame',4861,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car7','path',[parent_loc '/data_seq/UAV123/car7/'],'startFrame',1,'endFrame',1033,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car8_1','path',[parent_loc '/data_seq/UAV123/car8/'],'startFrame',1,'endFrame',1357,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car8_2','path',[parent_loc '/data_seq/UAV123/car8/'],'startFrame',1357,'endFrame',2575,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car9','path',[parent_loc '/data_seq/UAV123/car9/'],'startFrame',1,'endFrame',1879,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car10','path',[parent_loc '/data_seq/UAV123/car10/'],'startFrame',1,'endFrame',1405,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car11','path',[parent_loc '/data_seq/UAV123/car11/'],'startFrame',1,'endFrame',337,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car12','path',[parent_loc '/data_seq/UAV123/car12/'],'startFrame',1,'endFrame',499,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car13','path',[parent_loc '/data_seq/UAV123/car13/'],'startFrame',1,'endFrame',415,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car14','path',[parent_loc '/data_seq/UAV123/car14/'],'startFrame',1,'endFrame',1327,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car15','path',[parent_loc '/data_seq/UAV123/car15/'],'startFrame',1,'endFrame',469,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car16_1','path',[parent_loc '/data_seq/UAV123/car16/'],'startFrame',1,'endFrame',415,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car16_2','path',[parent_loc '/data_seq/UAV123/car16/'],'startFrame',415,'endFrame',1993,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car17','path',[parent_loc '/data_seq/UAV123/car17/'],'startFrame',1,'endFrame',1057,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car18','path',[parent_loc '/data_seq/UAV123/car18/'],'startFrame',1,'endFrame',1207,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...  
        struct('name','group1_1','path',[parent_loc '/data_seq/UAV123/group1/'],'startFrame',1,'endFrame',1333,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group1_2','path',[parent_loc '/data_seq/UAV123/group1/'],'startFrame',1333,'endFrame',2515,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group1_3','path',[parent_loc '/data_seq/UAV123/group1/'],'startFrame',2515,'endFrame',3925,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group1_4','path',[parent_loc '/data_seq/UAV123/group1/'],'startFrame',3925,'endFrame',4873,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group2_1','path',[parent_loc '/data_seq/UAV123/group2/'],'startFrame',1,'endFrame',907,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group2_2','path',[parent_loc '/data_seq/UAV123/group2/'],'startFrame',907,'endFrame',1771,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group2_3','path',[parent_loc '/data_seq/UAV123/group2/'],'startFrame',1771,'endFrame',2683,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group3_1','path',[parent_loc '/data_seq/UAV123/group3/'],'startFrame',1,'endFrame',1567,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group3_2','path',[parent_loc '/data_seq/UAV123/group3/'],'startFrame',1567,'endFrame',2827,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group3_3','path',[parent_loc '/data_seq/UAV123/group3/'],'startFrame',2827,'endFrame',4369,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','group3_4','path',[parent_loc '/data_seq/UAV123/group3/'],'startFrame',4369,'endFrame',5527,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person1','path',[parent_loc '/data_seq/UAV123/person1/'],'startFrame',1,'endFrame',799,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person2_1','path',[parent_loc '/data_seq/UAV123/person2/'],'startFrame',1,'endFrame',1189,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person2_2','path',[parent_loc '/data_seq/UAV123/person2/'],'startFrame',1189,'endFrame',2623,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person3','path',[parent_loc '/data_seq/UAV123/person3/'],'startFrame',1,'endFrame',643,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person4_1','path',[parent_loc '/data_seq/UAV123/person4/'],'startFrame',1,'endFrame',1501,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person4_2','path',[parent_loc '/data_seq/UAV123/person4/'],'startFrame',1501,'endFrame',2743,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person5_1','path',[parent_loc '/data_seq/UAV123/person5/'],'startFrame',1,'endFrame',877,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person5_2','path',[parent_loc '/data_seq/UAV123/person5/'],'startFrame',877,'endFrame',2101,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person6','path',[parent_loc '/data_seq/UAV123/person6/'],'startFrame',1,'endFrame',901,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person7_1','path',[parent_loc '/data_seq/UAV123/person7/'],'startFrame',1,'endFrame',1249,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person7_2','path',[parent_loc '/data_seq/UAV123/person7/'],'startFrame',1249,'endFrame',2065,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person8_1','path',[parent_loc '/data_seq/UAV123/person8/'],'startFrame',1,'endFrame',1075,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person8_2','path',[parent_loc '/data_seq/UAV123/person8/'],'startFrame',1075,'endFrame',1525,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person9','path',[parent_loc '/data_seq/UAV123/person9/'],'startFrame',1,'endFrame',661,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person10','path',[parent_loc '/data_seq/UAV123/person10/'],'startFrame',1,'endFrame',1021,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person11','path',[parent_loc '/data_seq/UAV123/person11/'],'startFrame',1,'endFrame',721,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person12_1','path',[parent_loc '/data_seq/UAV123/person12/'],'startFrame',1,'endFrame',601,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person12_2','path',[parent_loc '/data_seq/UAV123/person12/'],'startFrame',601,'endFrame',1621,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person13','path',[parent_loc '/data_seq/UAV123/person13/'],'startFrame',1,'endFrame',883,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person14_1','path',[parent_loc '/data_seq/UAV123/person14/'],'startFrame',1,'endFrame',847,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person14_2','path',[parent_loc '/data_seq/UAV123/person14/'],'startFrame',847,'endFrame',1813,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person14_3','path',[parent_loc '/data_seq/UAV123/person14/'],'startFrame',1813,'endFrame',2923,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person15','path',[parent_loc '/data_seq/UAV123/person15/'],'startFrame',1,'endFrame',1339,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person16','path',[parent_loc '/data_seq/UAV123/person16/'],'startFrame',1,'endFrame',1147,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person17_1','path',[parent_loc '/data_seq/UAV123/person17/'],'startFrame',1,'endFrame',1501,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person17_2','path',[parent_loc '/data_seq/UAV123/person17/'],'startFrame',1501,'endFrame',2347,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person18','path',[parent_loc '/data_seq/UAV123/person18/'],'startFrame',1,'endFrame',1393,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person19_1','path',[parent_loc '/data_seq/UAV123/person19/'],'startFrame',1,'endFrame',1243,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person19_2','path',[parent_loc '/data_seq/UAV123/person19/'],'startFrame',1243,'endFrame',2791,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person19_3','path',[parent_loc '/data_seq/UAV123/person19/'],'startFrame',2791,'endFrame',4357,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person20','path',[parent_loc '/data_seq/UAV123/person20/'],'startFrame',1,'endFrame',1783,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person21','path',[parent_loc '/data_seq/UAV123/person21/'],'startFrame',1,'endFrame',487,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person22','path',[parent_loc '/data_seq/UAV123/person22/'],'startFrame',1,'endFrame',199,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person23','path',[parent_loc '/data_seq/UAV123/person23/'],'startFrame',1,'endFrame',397,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','truck1','path',[parent_loc '/data_seq/UAV123/truck1/'],'startFrame',1,'endFrame',463,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','truck2','path',[parent_loc '/data_seq/UAV123/truck2/'],'startFrame',1,'endFrame',385,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','truck3','path',[parent_loc '/data_seq/UAV123/truck3/'],'startFrame',1,'endFrame',535,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','truck4_1','path',[parent_loc '/data_seq/UAV123/truck4/'],'startFrame',1,'endFrame',577,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),... 
        struct('name','truck4_2','path',[parent_loc '/data_seq/UAV123/truck4/'],'startFrame',577,'endFrame',1261,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),... 
        struct('name','uav1_1','path',[parent_loc '/data_seq/UAV123/uav1/'],'startFrame',1,'endFrame',1555,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav1_2','path',[parent_loc '/data_seq/UAV123/uav1/'],'startFrame',1555,'endFrame',2377,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav1_3','path',[parent_loc '/data_seq/UAV123/uav1/'],'startFrame',2473,'endFrame',3469,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav2','path',[parent_loc '/data_seq/UAV123/uav2/'],'startFrame',1,'endFrame',133,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav3','path',[parent_loc '/data_seq/UAV123/uav3/'],'startFrame',1,'endFrame',265,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav4','path',[parent_loc '/data_seq/UAV123/uav4/'],'startFrame',1,'endFrame',157,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav5','path',[parent_loc '/data_seq/UAV123/uav5/'],'startFrame',1,'endFrame',139,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav6','path',[parent_loc '/data_seq/UAV123/uav6/'],'startFrame',1,'endFrame',109,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav7','path',[parent_loc '/data_seq/UAV123/uav7/'],'startFrame',1,'endFrame',373,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','uav8','path',[parent_loc '/data_seq/UAV123/uav8/'],'startFrame',1,'endFrame',301,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard1','path',[parent_loc '/data_seq/UAV123/wakeboard1/'],'startFrame',1,'endFrame',421,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard2','path',[parent_loc '/data_seq/UAV123/wakeboard2/'],'startFrame',1,'endFrame',733,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard3','path',[parent_loc '/data_seq/UAV123/wakeboard3/'],'startFrame',1,'endFrame',823,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard4','path',[parent_loc '/data_seq/UAV123/wakeboard4/'],'startFrame',1,'endFrame',697,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard5','path',[parent_loc '/data_seq/UAV123/wakeboard5/'],'startFrame',1,'endFrame',1675,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard6','path',[parent_loc '/data_seq/UAV123/wakeboard6/'],'startFrame',1,'endFrame',1165,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard7','path',[parent_loc '/data_seq/UAV123/wakeboard7/'],'startFrame',1,'endFrame',199,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard8','path',[parent_loc '/data_seq/UAV123/wakeboard8/'],'startFrame',1,'endFrame',1543,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard9','path',[parent_loc '/data_seq/UAV123/wakeboard9/'],'startFrame',1,'endFrame',355,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','wakeboard10','path',[parent_loc '/data_seq/UAV123/wakeboard10/'],'startFrame',1,'endFrame',469,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car1_s','path',[parent_loc '/data_seq/UAV123/car1_s/'],'startFrame',1,'endFrame',1475,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car2_s','path',[parent_loc '/data_seq/UAV123/car2_s/'],'startFrame',1,'endFrame',320,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car3_s','path',[parent_loc '/data_seq/UAV123/car3_s/'],'startFrame',1,'endFrame',1300,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','car4_s','path',[parent_loc '/data_seq/UAV123/car4_s/'],'startFrame',1,'endFrame',830,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person1_s','path',[parent_loc '/data_seq/UAV123/person1_s/'],'startFrame',1,'endFrame',1600,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person2_s','path',[parent_loc '/data_seq/UAV123/person2_s/'],'startFrame',1,'endFrame',250,'nz',6,'ext','jpg','init_rect', [0,0,0,0]),...
        struct('name','person3_s','path',[parent_loc '/data_seq/UAV123/person3_s/'],'startFrame',1,'endFrame',505,'nz',6,'ext','jpg','init_rect', [0,0,0,0])
    };
end
