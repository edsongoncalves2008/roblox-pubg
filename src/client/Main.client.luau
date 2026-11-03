local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local Run=game:GetService('RunService')
local RS=game:GetService('ReplicatedStorage')
local Debris=game:GetService('Debris')
local player=Players.LocalPlayer
local remote=RS:WaitForChild('GameAction')
local Config=require(RS:WaitForChild('Shared'):WaitForChild('Config'))
local camera=workspace.CurrentCamera
local state={Weapon='M416',Ammo=30,Reserve=180,Kills=0}
local firing=false;local ads=false;local sprint=false;local crouch=false;local fps=false;local last=0;local recoil=0
local gui=Instance.new('ScreenGui');gui.Name='JungleHUD';gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild('PlayerGui')
local function label(name,size,pos,text)
 local l=Instance.new('TextLabel');l.Name=name;l.Size=size;l.Position=pos;l.BackgroundColor3=Color3.fromRGB(19,27,23);l.BackgroundTransparency=.25;l.TextColor3=Color3.fromRGB(235,235,217);l.Font=Enum.Font.GothamMedium;l.TextScaled=true;l.Text=text;l.Parent=gui;return l
end
local info=label('Status',UDim2.fromOffset(330,64),UDim2.new(.5,-165,1,-90),'')
local cross=label('Crosshair',UDim2.fromOffset(24,24),UDim2.new(.5,-12,.5,-12),'+');cross.BackgroundTransparency=1
local feed=label('Feed',UDim2.new(.4,0,0,35),UDim2.new(.6,-10,0,25),'JUNGLE BATTLEGROUNDS · TREINO')
local help=label('Controls',UDim2.new(.6,0,0,35),UDim2.new(.2,0,0,70),'WASD mover · Shift correr · C agachar · V FPS/TPS · RMB mira · R recarga · 1/2 arma')
help.TextScaled=false;help.TextSize=14;help.TextWrapped=true
local function stance()
 remote:FireServer('Move',ads and 'ADS' or crouch and 'Crouch' or sprint and 'Sprint' or 'Walk')
end
local function act(name,input)
 local begin=input==Enum.UserInputState.Begin
 if name=='Fire' then firing=begin
 elseif name=='Aim' then ads=begin;stance()
 elseif name=='Sprint' then sprint=begin;stance()
 elseif name=='Crouch' and begin then crouch=not crouch;stance()
 elseif name=='Camera' and begin then fps=not fps
 elseif name=='Reload' and begin then remote:FireServer('Reload')
 elseif name=='Primary' and begin then remote:FireServer('Equip','M416')
 elseif name=='Secondary' and begin then remote:FireServer('Equip','AKM') end
 return Enum.ContextActionResult.Sink
end
CAS:BindAction('Fire',act,true,Enum.UserInputType.MouseButton1)
CAS:BindAction('Aim',act,true,Enum.UserInputType.MouseButton2)
CAS:BindAction('Sprint',act,true,Enum.KeyCode.LeftShift)
CAS:BindAction('Crouch',act,true,Enum.KeyCode.C)
CAS:BindAction('Camera',act,true,Enum.KeyCode.V)
CAS:BindAction('Reload',act,true,Enum.KeyCode.R)
CAS:BindAction('Primary',act,false,Enum.KeyCode.One)
CAS:BindAction('Secondary',act,false,Enum.KeyCode.Two)
for index,name in ipairs({'Fire','Aim','Reload','Crouch','Camera','Sprint'}) do CAS:SetTitle(name,name);CAS:SetPosition(name,UDim2.new(1,-90-(index%3)*80,1,-110-math.floor((index-1)/3)*80)) end
UIS.WindowFocusReleased:Connect(function() firing=false;ads=false;sprint=false;stance() end)
remote.OnClientEvent:Connect(function(action,data)
 if action=='State' then state=data
 elseif action=='Kill' then feed.Text=data
 elseif action=='Hit' then cross.TextColor3=Color3.fromRGB(255,90,65);task.delay(.12,function() cross.TextColor3=Color3.fromRGB(235,235,217) end)
 elseif action=='Impact' then
  local p=Instance.new('Part');p.Shape=Enum.PartType.Ball;p.Size=Vector3.new(.18,.18,.18);p.Position=data;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(224,185,110);p.Parent=workspace;Debris:AddItem(p,.15)
 elseif action=='Shot' then
  local char=data.Player.Character;local head=char and char:FindFirstChild('Head')
  if head then local light=Instance.new('PointLight');light.Color=Color3.fromRGB(255,191,95);light.Brightness=2;light.Range=10;light.Parent=head;Debris:AddItem(light,.05) end
 end
end)
Run.RenderStepped:Connect(function(dt)
 local char=player.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
 if not hum or hum.Health<=0 then firing=false;return end
 UIS.MouseBehavior=Enum.MouseBehavior.LockCenter
 player.CameraMode=fps and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
 player.CameraMinZoomDistance=fps and .5 or (ads and 3 or 7)
 player.CameraMaxZoomDistance=fps and .5 or (ads and 3 or 7)
 hum.CameraOffset=hum.CameraOffset:Lerp(Vector3.new(fps and 0 or 2,crouch and -1 or 0,0),math.min(1,dt*12))
 camera.FieldOfView+=((ads and 48 or 75)-camera.FieldOfView)*math.min(1,dt*12)
 if recoil>0 then local amount=math.min(recoil,dt*20);camera.CFrame*=CFrame.Angles(math.rad(amount),0,0);recoil-=amount end
 local w=Config.Weapons[state.Weapon]
 if firing and not state.Reloading and state.Ammo>0 and os.clock()-last>=w.Interval then
  last=os.clock();local ray=camera:ViewportPointToRay(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
  remote:FireServer('Fire',{Origin=ray.Origin,Direction=ray.Direction.Unit});recoil+=w.Recoil
 end
 info.Text=string.format('HP %d  |  ELIM %d\n%s  %d / %d %s',hum.Health,state.Kills,state.Weapon,state.Ammo,state.Reserve,state.Reloading and 'RECARREGANDO' or '')
end)
