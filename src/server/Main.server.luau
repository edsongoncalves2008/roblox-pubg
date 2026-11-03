local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local Config=require(RS.Shared.Config)
local spawns=require(script.Parent.World).build()
local remote=Instance.new('RemoteEvent');remote.Name='GameAction';remote.Parent=RS
local states={};local bullets={};local rng=Random.new()
local function finite(v) return typeof(v)=='Vector3' and v.X==v.X and v.Y==v.Y and v.Z==v.Z and v.Magnitude<1e6 end
local function sync(p,s) remote:FireClient(p,'State',{Weapon=s.weapon,Ammo=s.ammo,Reserve=s.reserve,Reloading=s.reloading,Kills=s.kills}) end
local function equip(p,s,name)
 if s.weapon and s.ammo then s.slots[s.weapon]={ammo=s.ammo,reserve=s.reserve} end
 s.weapon=name;local slot=s.slots[name];s.ammo=slot and slot.ammo or Config.Weapons[name].Magazine;s.reserve=slot and slot.reserve or 180;s.reloading=false;s.generation+=1
 local char=p.Character;if not char then return end
 local old=char:FindFirstChild('Weapon');if old then old:Destroy() end
 local hand=char:FindFirstChild('RightHand') or char:FindFirstChild('Right Arm');if not hand then return end
 local model=Instance.new('Model');model.Name='Weapon';model.Parent=char
 local function piece(n,size,offset,color)
  local part=Instance.new('Part');part.Name=n;part.Size=size;part.Color=color;part.Material=Enum.Material.Metal;part.CanCollide=false;part.Massless=true;part.CFrame=hand.CFrame*offset;part.Parent=model
  local weld=Instance.new('WeldConstraint');weld.Part0=hand;weld.Part1=part;weld.Parent=part;return part
 end
 piece('Receiver',Vector3.new(.35,.5,1.6),CFrame.new(0,-.1,-.5),Color3.fromRGB(48,52,47))
 piece('Barrel',Vector3.new(.14,.14,1.8),CFrame.new(0,.05,-2),Color3.fromRGB(30,30,30))
 piece('Stock',Vector3.new(.3,.4,.8),CFrame.new(0,-.05,.6),Color3.fromRGB(91,77,52))
 piece('Magazine',Vector3.new(.25,.8,.5),CFrame.new(0,-.6,-.4),Color3.fromRGB(42,42,40))
 sync(p,s)
end
local function join(p)
 local s={slots={},weapon='M416',ammo=30,reserve=180,lastShot=0,tokens=30,tokenTime=os.clock(),kills=0,generation=0,reloading=false};states[p]=s
 p.CharacterAdded:Connect(function(char)
  s.generation+=1;s.reloading=false;s.slots={};s.ammo=nil;s.reserve=nil
  local hum=char:WaitForChild('Humanoid');hum.MaxHealth=100;hum.Health=100;hum.WalkSpeed=Config.WalkSpeed
  char:WaitForChild('HumanoidRootPart');char:PivotTo(CFrame.new(spawns[rng:NextInteger(1,#spawns)]))
  equip(p,s,s.weapon)
  hum.Died:Connect(function()
   local killer=hum:GetAttribute('Attacker');local attacker=killer and Players:GetPlayerByUserId(killer)
   if attacker and attacker~=p and states[attacker] then states[attacker].kills+=1;sync(attacker,states[attacker]);remote:FireAllClients('Kill',attacker.DisplayName..' eliminou '..p.DisplayName) end
  end)
 end)
end
Players.PlayerAdded:Connect(join);for _,p in ipairs(Players:GetPlayers()) do join(p) end
Players.PlayerRemoving:Connect(function(p) states[p]=nil end)
remote.OnServerEvent:Connect(function(p,action,data)
 local s=states[p];local char=p.Character;local hum=char and char:FindFirstChildOfClass('Humanoid');local root=char and char:FindFirstChild('HumanoidRootPart')
 if not s or not hum or hum.Health<=0 or not root then return end
 local now=os.clock();s.tokens=math.min(30,s.tokens+(now-s.tokenTime)*20);s.tokenTime=now;if s.tokens<1 then return end;s.tokens-=1
 local w=Config.Weapons[s.weapon]
 if action=='Move' and type(data)=='string' then
  local speeds={Walk=Config.WalkSpeed,Sprint=Config.SprintSpeed,Crouch=Config.CrouchSpeed,ADS=8}
  if speeds[data] then hum.WalkSpeed=speeds[data];hum:SetAttribute('Stance',data) end
 elseif action=='Equip' and Config.Weapons[data] then
  if not s.reloading and now-s.lastShot>0.5 then equip(p,s,data);s.lastShot=now end
 elseif action=='Reload' then
  if s.reloading or s.ammo>=w.Magazine or s.reserve<=0 then return end
  s.reloading=true;local gen=s.generation;sync(p,s)
  task.delay(w.Reload,function()
   if states[p]~=s or s.generation~=gen or hum.Health<=0 then return end
   local n=math.min(w.Magazine-s.ammo,s.reserve);s.ammo+=n;s.reserve-=n;s.reloading=false;sync(p,s)
  end)
 elseif action=='Fire' and type(data)=='table' then
  if not finite(data.Origin) or not finite(data.Direction) or math.abs(data.Direction.Magnitude-1)>0.02 then return end
  local head=char:FindFirstChild('Head');if not head or (data.Origin-head.Position).Magnitude>12 then return end
  local params=RaycastParams.new();params.FilterDescendantsInstances={char};params.IgnoreWater=true
  if workspace:Raycast(head.Position,data.Origin-head.Position,params) then return end
  if s.reloading or s.ammo<=0 or now-s.lastShot<w.Interval*0.95 or #bullets>=512 then return end
  s.lastShot=now;s.ammo-=1;sync(p,s)
  local direction=(data.Direction+Vector3.new(rng:NextNumber(-w.Spread,w.Spread),rng:NextNumber(-w.Spread,w.Spread),rng:NextNumber(-w.Spread,w.Spread))).Unit
  table.insert(bullets,{position=data.Origin,velocity=direction*w.Speed,distance=0,weapon=w,params=params,owner=p})
  remote:FireAllClients('Shot',{Player=p,Position=head.Position})
 end
end)
RunService.Heartbeat:Connect(function(dt)
 -- Fixed maximum simulation step, swept rays prevent tunneling.
 dt=math.min(dt,0.25)
 for i=#bullets,1,-1 do
  local b=bullets[i];local remove=false;local remaining=dt
  while remaining>0 and not remove do
   local step=math.min(remaining,1/60);remaining-=step
   local delta=b.velocity*step+Vector3.new(0,-b.weapon.Gravity*step*step/2,0)
   local hit=workspace:Raycast(b.position,delta,b.params)
   b.velocity+=Vector3.new(0,-b.weapon.Gravity*step,0);b.distance+=delta.Magnitude
   if hit then
    local model=hit.Instance:FindFirstAncestorOfClass('Model');local target=model and model:FindFirstChildOfClass('Humanoid')
    if target and target.Health>0 then
     local damage=b.weapon.Damage*(hit.Instance.Name=='Head' and b.weapon.HeadMultiplier or 1)
     target:SetAttribute('Attacker',b.owner.UserId);target:TakeDamage(damage)
     if b.owner.Parent then remote:FireClient(b.owner,'Hit',damage) end
    end
    remote:FireAllClients('Impact',hit.Position);remove=true
   elseif b.distance>b.weapon.Range then remove=true else b.position+=delta end
  end
  if remove then table.remove(bullets,i) end
 end
end)
-- Local training targets are real Humanoids and use the same damage path.
for i=1,6 do
 local model=Instance.new('Model');model.Name='TrainingTarget';model.Parent=workspace
 local torso=Instance.new('Part');torso.Name='HumanoidRootPart';torso.Size=Vector3.new(4,5,2);torso.Position=Vector3.new(-25+i*9,18,-105);torso.Anchored=true;torso.Color=Color3.fromRGB(145,86,49);torso.Parent=model
 local head=Instance.new('Part');head.Name='Head';head.Shape=Enum.PartType.Ball;head.Size=Vector3.new(2,2,2);head.Position=torso.Position+Vector3.new(0,3.5,0);head.Anchored=true;head.Parent=model
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=model
 -- Targets stay eliminated until the next server session.
 h.BreakJointsOnDeath=false
end
