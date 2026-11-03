local World = {}
function World.build()
 local terrain = workspace.Terrain
 local root = Instance.new('Folder'); root.Name='Map'; root.Parent=workspace
 local rng=Random.new(7319)
 local function part(name,size,cf,material,color,parent)
  local p=Instance.new('Part'); p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Material=material;p.Color=color;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root;return p
 end
 terrain:FillBlock(CFrame.new(0,-24,0),Vector3.new(1800,32,1800),Enum.Material.Water)
 for x=-736,736,64 do for z=-736,736,64 do
  local edge=math.max(math.abs(x),math.abs(z))
  local height=math.max(-10,10+math.noise(x/360,z/360)*42-(math.max(0,edge-610)/3))
  terrain:FillBlock(CFrame.new(x,height/2-12,z),Vector3.new(64,height+24,64),edge>650 and Enum.Material.Sand or Enum.Material.Grass)
 end end
 local pois={{'Bootcamp',0,0},{'Paradise Grove',350,-350},{'River Village',-350,320},{'Temple Ruins',370,350}}
 local spawns={}
 for _,poi in ipairs(pois) do
  local name,x,z=poi[1],poi[2],poi[3]
  terrain:FillBlock(CFrame.new(x,2,z),Vector3.new(230,24,230),Enum.Material.Ground)
  local model=Instance.new('Model');model.Name=name;model.Parent=root
  for i=1,4 do
   local bx=x+((i-1)%2)*100-50;local bz=z+math.floor((i-1)/2)*100-50
   local base=CFrame.new(bx,15,bz)
   local concrete=Color3.fromRGB(142,139,119)
   part('Floor',Vector3.new(64,2,48),base,Enum.Material.Concrete,concrete,model)
   -- Front wall split around an actual walk-through doorway; side windows are open gaps.
   for _,dx in ipairs({-22,22}) do part('DoorWall',Vector3.new(20,18,2),base*CFrame.new(dx,10,-24),Enum.Material.Concrete,concrete,model) end
   part('DoorLintel',Vector3.new(24,5,2),base*CFrame.new(0,16.5,-24),Enum.Material.Concrete,concrete,model)
   part('BackWall',Vector3.new(64,18,2),base*CFrame.new(0,10,24),Enum.Material.Concrete,concrete,model)
   for _,dx in ipairs({-32,32}) do
    part('WindowSill',Vector3.new(2,6,48),base*CFrame.new(dx,4,0),Enum.Material.Concrete,concrete,model)
    part('WindowHeader',Vector3.new(2,5,48),base*CFrame.new(dx,16.5,0),Enum.Material.Concrete,concrete,model)
    for _,dz in ipairs({-19,19}) do part('WindowPillar',Vector3.new(2,8,10),base*CFrame.new(dx,10,dz),Enum.Material.Concrete,concrete,model) end
   end
   part('Roof',Vector3.new(68,2,52),base*CFrame.new(0,20,0),Enum.Material.Metal,Color3.fromRGB(80,90,78),model)
   for step=1,20 do part('Stairs',Vector3.new(10,1,3),base*CFrame.new(40,step-1,30-step*3),Enum.Material.Concrete,concrete,model) end
   for c=1,3 do part('Cover',Vector3.new(6,5,5),base*CFrame.new(-18+c*10,3,8),Enum.Material.WoodPlanks,Color3.fromRGB(105,79,48),model) end
   table.insert(spawns,Vector3.new(bx,20,bz))
  end
  part('Road',Vector3.new(20,1,230),CFrame.new(x,14.2,z),Enum.Material.Asphalt,Color3.fromRGB(65,65,58))
 end
 for _=1,400 do
  local x,z=rng:NextNumber(-640,640),rng:NextNumber(-640,640)
  local clear=false
  for _,poi in ipairs(pois) do if math.abs(x-poi[2])<130 and math.abs(z-poi[3])<130 then clear=true end end
  if not clear then
   local hit=workspace:Raycast(Vector3.new(x,150,z),Vector3.new(0,-250,0))
   if hit and hit.Material~=Enum.Material.Water then
    local y=hit.Position.Y
    local trunk=part('PalmTrunk',Vector3.new(3,26,3),CFrame.new(x,y+13,z)*CFrame.Angles(0,0,0.08),Enum.Material.Wood,Color3.fromRGB(107,88,59))
    trunk.Shape=Enum.PartType.Cylinder;trunk.Size=Vector3.new(26,3,3);trunk.CFrame=CFrame.new(x,y+13,z)*CFrame.Angles(0,0,math.pi/2-0.08)
    for a=0,5 do
     local leaf=Instance.new('WedgePart');leaf.Name='PalmFrond';leaf.Size=Vector3.new(7,2,19);leaf.CFrame=CFrame.new(x,y+26,z)*CFrame.Angles(0,a*math.pi/3,0)*CFrame.new(0,0,7)*CFrame.Angles(-0.2,0,0);leaf.Anchored=true;leaf.CanCollide=false;leaf.Material=Enum.Material.Grass;leaf.Color=Color3.fromRGB(49,88,40);leaf.Parent=root
    end
   end
  end
 end
 local lighting=game:GetService('Lighting');lighting.ClockTime=14;lighting.Brightness=2;lighting.Ambient=Color3.fromRGB(115,130,110)
 local atmosphere=Instance.new('Atmosphere');atmosphere.Density=0.28;atmosphere.Color=Color3.fromRGB(194,218,202);atmosphere.Parent=lighting
 return spawns
end
return World
