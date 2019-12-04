clear
clc

%define variables numMagnets in Fusion 360 is 34 and numMagnets2 is 40
numMagnets=32;
numMagnets2=38;
%actual inner radius is 10.18cm in Fusion 360, outer radius is 12 cm rn
radius=10.18;
radius2=12;

%creates evenly spaced array from 0 to 2pi (not including 2pi)
angle_elements=(0:numMagnets-1)*(2*pi/numMagnets); 
angle_elements2=(0:numMagnets2-1)*(2*pi/numMagnets2);
% defines center of magnets' position around ring
position=[radius*cos(angle_elements);radius*sin(angle_elements);zeros*(angle_elements)]';
position2=[radius2*cos(angle_elements2);radius2*sin(angle_elements2);zeros*(angle_elements2)]';
% defines rotation of each individual magnet on its own axis
rotation = 2*angle_elements;
rotation2 = 2*angle_elements2;
rotationdegrees = rotation * (180/pi);
rotationdegrees2 = rotation2 * (180/pi);
array1 = (2:numMagnets+1);
array2 = ((numMagnets+1):(numMagnets+1)+numMagnets2);

%create new comsol model
import com.comsol.model.*
import com.comsol.model.util.*
model = ModelUtil.create('Model');
geom1 = model.geom.create('geom1',3);
phy1 = model.physics.create('phy1', 'MagnetostaticsNoCurrents','geom1');
model.component('mod1').geom('geom1').create('sph1', 'Sphere');
model.component('mod1').geom('geom1').feature('sph1').set('r', 20);
model.component('mod1').geom('geom1').run('sph1');
model.component('mod1').physics('phy1').selection.all;
model.selection('sel1').set(array1)
model.component("mod1").selection().create("sel2", "Explicit");
model.selection('sel1').geom(3)
model.selection('sel1').set('array2')
for i=1:numMagnets
   tag = model.geom('geom1').feature().uniquetag('blk');
   model.geom('geom1').feature().create(tag,'Block');
   model.geom('geom1').feature(tag).set('size', [1.27 1.27 1.27]);
   %model.material.create('Magnet');
   %model.material('Magnet').materialmodel.create('Magnet');
   %model.material('Magnet').materialmodel('Magnet').set('density', 7500)
   %model.material('Magnet').materialmodel('Magnet').set('electricalconductivity', .667E6)
   %model.material('Magnet').materialmodel('Magnet').set('relativepermittivity', 1)
   %model.material('Magnet').materialmodel('Magnet').set('relativepermeabilty', 1.05)
   %model.material('Magnet').materialmodel('Magnet').set('recoilpermeability', 1.05)
   %model.material('Magnet').materialmodel('Magnet').set('remanentfluxdensitynorm', 1.2)
  
   tag2 = model.physics('phy1').feature().uniquetag('mfc');
   model.physics('phy1').feature().create(tag2, 'MagneticFluxConservation',3);
   model.component('mod1').physics('phy1').feature(tag2).set('ConstitutiveRelationBH', 'RemanentFluxDensity');
   model.component('mod1').physics('phy1').feature(tag2).set('normBr_crel_BH_RemanentFluxDensity_mat', 'userdef');
   model.component('mod1').physics('phy1').feature(tag2).set('mur_crel_BH_RemanentFluxDensity_mat', 'userdef');
   model.component('mod1').physics('phy1').feature(tag2).set('normBr_crel_BH_RemanentFluxDensity', 1.2);
   model.component('mod1').physics('phy1').feature(tag2).set('mur_crel_BH_RemanentFluxDensity', [1.05 0 0 0 1.05 0 0 0 1.05]);
   model.component('mod1').physics('phy1').feature(tag2).set('e_crel_BH_RemanentFluxDensity', [0 1 0]);
   model.geom('geom1').feature(tag).set('pos', position(i,:));
   model.geom('geom1').run(tag);
   model.geom('geom1').feature(tag).set('base', 'center')
   model.geom('geom1').feature(tag).set('rot',rotationdegrees(i));
end

for i=1:numMagnets2
   tag = model.geom('geom1').feature().uniquetag('blk_');
   tag2 = model.physics('phy1').feature().uniquetag('mfc_');
   model.geom('geom1').feature().create(tag,'Block');
   model.physics('phy1').feature().create(tag2, 'MagneticFluxConservation',3);
   model.component('mod1').physics('phy1').feature(tag2).set('ConstitutiveRelationBH', 'RemanentFluxDensity');
   model.component('mod1').physics('phy1').feature(tag2).set('normBr_crel_BH_RemanentFluxDensity_mat', 'userdef');
   model.component('mod1').physics('phy1').feature(tag2).set('mur_crel_BH_RemanentFluxDensity_mat', 'userdef');
   model.component('mod1').physics('phy1').feature(tag2).set('normBr_crel_BH_RemanentFluxDensity', 1.2);
   model.component('mod1').physics('phy1').feature(tag2).set('mur_crel_BH_RemanentFluxDensity', [1.05 0 0 0 1.05 0 0 0 1.05]);
   model.component('mod1').physics('phy1').feature(tag2).set('e_crel_BH_RemanentFluxDensity', [0 1 0]);
   model.geom('geom1').feature(tag).set('size', [1.27 1.27 1.27]);
   model.geom('geom1').feature(tag).set('pos', position2(i,:));
   model.geom('geom1').run(tag);
   model.geom('geom1').feature(tag).set('base', 'center')
   model.geom('geom1').feature(tag).set('rot',rotationdegrees2(i));
end
model.mesh.create('mesh1','geom1');
mphgeom(model)
mphsave(model,'CompletedDoubleHalbachArrayTag')