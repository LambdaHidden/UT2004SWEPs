AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true

function ENT:Initialize()
	self:SetModel("models/ut2004/onsweapons-a/parasitemine.mdl")
	self:SetHealth(10)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,8) )
	
	self.SearchRadius 	= 800	-- How far to search for enemies
	
	self.TargetPainted = false
	self.TargetPos = vector_origin
	self.Crouched = false
	
	if SERVER then
		self:SetMaxVisionRange(1200)
		self:SetBloodColor(DONT_BLEED)
		self.loco:SetStepHeight(18)
		self.loco:SetDeathDropHeight(500)
	end
	
	if !self:OnGround() then
		if SERVER then self:StartActivity(ACT_STAND) end
		self:SetPlaybackRate(0.5)
	end
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end

function ENT:SetTargetPos(pos)
	self.TargetPos = pos
	/*if !self.Crouched then
		self:CoroutineOverride(function(self)
			self:MoveToPos(self:GetTargetPos(), {repath = 0.25, tolerance = 64})
		end)
	end*/
end
function ENT:GetTargetPos()
	return self.TargetPos
end

function ENT:HaveEnemy()
	local enemy = self:GetEnemy()
	-- If our current enemy is valid
	if IsValid(enemy) and enemy:Health() > 0 then
		-- If the enemy is too far
		if self:GetRangeSquaredTo(enemy:GetPos()) > self:GetMaxVisionRange() * self:GetMaxVisionRange() then
			-- If the enemy is lost then call FindEnemy() to look for a new one
			-- FindEnemy() will return true if an enemy is found, making this function return true
			return self:FindEnemy()
		end	
		-- The enemy is neither too far nor too dead so we can return true
		return true
	else
		-- The enemy isn't valid so lets look for a new one
		return self:FindEnemy()
	end
end

function ENT:FindEnemy()
	local _ents = ents.FindInSphere( self:GetPos(), self.SearchRadius )
	local own = self.Owner
	for k,v in ipairs( _ents ) do
		if own then
			if (!cvars.Bool("ai_ignoreplayers") and v:IsPlayer() and own:Team() != v:Team()) or ((v:IsNPC() or v:IsNextBot()) and (v.GetRelationship and v:GetRelationShip(own) or v.Disposition and v:Disposition(own)) == D_HT) then
				self:SetEnemy(v)
				return true
			end
		else
			if (v:IsNPC() or (v:IsNextBot() and v:GetClass() != "ut2004_spidermine")) or (!cvars.Bool("ai_ignoreplayers") and v:IsPlayer()) then
				self:SetEnemy(v)
				return true
			end
		end
	end	
	self:SetEnemy(nil)
	return false
end
/*
function ENT:CoroutineOverride(callback)
    local oldThread = self.BehaveThread
    self.BehaveThread = coroutine.create(function()
        callback(self)
        self.BehaveThread = oldThread
    end)
end
*/
function ENT:RunBehaviour()
	-- This function is called when the entity is first spawned, it acts as a giant loop that will run as long as the NPC exists
	
	while true do
		if cvars.Bool("ai_disabled") then 
			coroutine.wait(0.25)
			continue
		end
		if self:OnGround() then
			if self:HaveEnemy() then
				self:PlaySequenceAndWait("startup")
				self.Crouched = false
				self.loco:FaceTowards(self:GetEnemy():GetPos())
				self:StartActivity( ACT_RUN )
				self.loco:SetDesiredSpeed(450)		-- Set the speed that we will be moving at. Don't worry, the animation will speed up/slow down to match
				self.loco:SetAcceleration(1024)
				self.loco:SetDeceleration(1024)
				self:ChaseEnemy() 						-- The new function like MoveToPos that will be looked at soon.
				self:PlaySequenceAndWait("look")	-- Lets play a fancy animation when we stop moving
			elseif self.TargetPainted and self:GetRangeSquaredTo(self:GetTargetPos()) > 4096 then
				self:PlaySequenceAndWait("startup")
				self.Crouched = false
				self.loco:FaceTowards(self:GetTargetPos())
				self:StartActivity( ACT_RUN )
				self.loco:SetDesiredSpeed(450)
				self.loco:SetAcceleration(1024)
				self.loco:SetDeceleration(1024)
				self:MoveToPos(self:GetTargetPos(), {repath = 0.25, tolerance = 64})
				self.TargetPainted = false
			else
				if !self.Crouched then
					self:PlaySequenceAndWait("closedown")
					self:StartActivity( ACT_IDLE )
					self.Crouched = true
				end
			end
		end
		coroutine.wait(0.25)
	end
end

function ENT:ChaseEnemy( options )

	local options = options or {}
	local path = Path( "Chase" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemy's position

	if !path:IsValid() then return "failed" end
	
	while path:IsValid() and self:HaveEnemy() do
		local maxs = self:GetEnemy():OBBMaxs().z
		if self:GetRangeSquaredTo(self:GetEnemy()) < maxs*maxs then
			self.loco:SetJumpHeight(math.Clamp(maxs - 16, 8, maxs))
			self.loco:FaceTowards(self:GetEnemy():GetPos())
			self.loco:Jump()
		end
	
		if ( path:GetAge() > 0.2 ) then					-- Since we are following the player we have to constantly remake the path
			path:Compute(self, self:GetEnemy():GetPos())-- Compute the path towards the enemy's position again
		end
		path:Update( self )								-- This function moves the bot along the path
		
		if ( options.draw ) then path:Draw() end
		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:Think()
	if SERVER then
	if !self:OnGround() then
		local ang = self:GetAngles()
		if math.Round(ang.p) != 0 or math.Round(ang.r) != 0 then
			ang.p = ang.p + (ang.p > 0 and -engine.TickInterval()*120 or engine.TickInterval()*120)
			ang.r = ang.r + (ang.r > 0 and -engine.TickInterval()*120 or engine.TickInterval()*120)
			self:SetAngles(ang)
		end
		
		--local colcheck = self:CollisionCheck()
		--if colcheck.Entity == self:GetEnemy() then
			--self:Explode()
		--end
		if self:HaveEnemy() and self:GetPos():DistToSqr(self:GetEnemy():WorldSpaceCenter()) < 4096 then
			self:Explode()
		end
	else
		local normal = self.loco:GetGroundNormal()
		
		local test = normal:Angle()
		test:RotateAroundAxis(normal, self:GetAngles().y - test.y)
		test.p = test.p + 90
		self:SetAngles(test)
	end
	end
end

function ENT:OnLandOnGround( ent )
	self:SetPlaybackRate(1)
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	
	if self:HaveEnemy() then
		self:StartActivity( ACT_RUN )
	elseif !self.TargetPainted then 
		self:StartActivity( ACT_LAND )
		self:EmitSound("ut2004/weaponsounds/baseguntech/BGrenfloor1.wav")
	end
end

function ENT:CollisionCheck()
	local trdata = {
		start = self:GetPos() + Vector(0,0,8),
		endpos = self:GetPos() + self:OBBCenter(),
		mins = self:OBBMins()*1.5,
		maxs = self:OBBMaxs()*1.5,
		filter = self
	}
	return util.TraceHull(trdata)
end

function ENT:HandleStuck()
	if self.TargetPainted then
		local path = Path( "Follow" )
		path:SetMinLookAheadDistance(300)
		path:SetGoalTolerance(20)
		path:Compute( self, self:GetTargetPos() )
		
		if !path:IsValid() then 
			self:Explode()
			return "failed" 
		end
		--self:SetAngles((path:FirstSegment().pos - self:GetPos()):Angle())
		self.loco:SetDesiredSpeed( 1 )
		self:PlaySequenceAndWait("look")
		self:SetPos(path:FirstSegment().pos)
		self.loco:ClearStuck()
		self.loco:SetDesiredSpeed( 450 )
		self.loco:FaceTowards(self:GetTargetPos())
		self:StartActivity( ACT_RUN )
		self:MoveToPos(self:GetTargetPos(), {repath = 0.25, tolerance = 64})
	else
		self:Explode()
	end
end

function ENT:Explode()
	util.BlastDamage( self, self.Owner or self, self:GetPos(), 128, 95 )
	self:EmitSound("ut2004/weaponsounds/basefiringsounds/BRocketLauncherFire.wav")
	ParticleEffect( "ut2004_gl_explosion", self:GetPos(), angle_zero )
	self:Remove()
end

function ENT:OnKilled(dmginfo)
	if self:Health() < 0 then return end
	if dmginfo:GetAttacker() != self.Owner then
		hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	end
	self:Explode()
	self:Remove()
end

list.Set( "NPC", "ut2004_spidermine", 
{	Name = "Spider Mine", 
	Class = "ut2004_spidermine",
	Category = "UT2004"	
})