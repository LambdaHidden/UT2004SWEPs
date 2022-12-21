ENT.Type			= "anim"
ENT.PrintName		= "UT2004 Bio"
ENT.Author			= "Hidden"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT





ENT.BaseDamage		= 20
ENT.Damage			= 19
ENT.DamageRadius 	= 72

ENT.RestTime		= 2.25
ENT.DripTime		= 1.8
ENT.MaxGoopLevel	= 5
ENT.GoopLevel		= 1
ENT.GoopVolume		= 1
--ENT.Speed			= 1222 --?
ENT.GoblingSpeed	= 122 --?
ENT.LifeSpan		= 20.0

ENT.ShouldMerge		= true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State") -- 0 is Flying, 1 is OnGround, 2 is Shriveling.
	self:NetworkVar("Float", 0, "DrawScale")
end

function ENT:Landed(data)
	self:EmitSound("ut2004/weaponsounds/biorifle/BBioRifleGoo"..math.random(1,2)..".wav")
	
	local CoreGoopLevel = self.Rand3 + self.MaxGoopLevel - 3 -- Spawn goblings
	if self.GoopLevel > CoreGoopLevel then
		self:SplashGlobs(self.GoopLevel - CoreGoopLevel)
		self:SetGoopLevel(CoreGoopLevel)
	end
	-- Spawn a green stain decal here
	
	--self:SetMoveType(MOVETYPE_NONE)
	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
	self:SetPos(data.HitPos)
	self:SetAngles(data.HitNormal:Angle())
	--self:SetCollisionSize(self.GoopVolume*10.0)
	
	self:SetState(1)
	self.ShouldMerge = true
	
	-- This is to handle sticking to a wall and then dripping.
	self:ResetSequence(self:LookupSequence("hit"))
	self:LandedRest(false)
	self:LandedSlide()
end

function ENT:MergeWithGlob(AdditionalGoopLevel)
	local NewGoopLevel, ExtraSplash
	NewGoopLevel = AdditionalGoopLevel + self.GoopLevel
	if NewGoopLevel > self.MaxGoopLevel then
		self.Rand3 = (self.Rand3 + 1) % 3
		ExtraSplash = self.Rand3
		self:SplashGlobs(NewGoopLevel - self.MaxGoopLevel + ExtraSplash)
		NewGoopLevel = self.MaxGoopLevel - ExtraSplash
	end
	self:SetGoopLevel(NewGoopLevel)
	--self:SetCollisionSize(self.GoopVolume*10.0)
	self:EmitSound("ut2004/weaponsounds/biorifle/BBioRifleGoo"..math.random(1,2)..".wav")
	self:ResetSequence(self:LookupSequence("hit"))
	self:LandedRest(true)
	self:LandedSlide()
end

function ENT:SplashGlobs(NumGloblings)
	local fwrd = self:GetForward()
	
	for i=0, NumGloblings do
		local NewGlob = ents.Create("ut2004_bio")
		NewGlob:SetPos(self:GetPos() - self.GoopVolume*8*fwrd) --(self:GetPos() + self.GoopVolume*(self:GetModelScale()/2)*fwrd)
		NewGlob:SetAngles(AngleRand())
		NewGlob:SetOwner(self.Owner)
		NewGlob.ShouldMerge = false
		NewGlob:Spawn()
		NewGlob:Activate()
		local phys = NewGlob:GetPhysicsObject()
		if phys then
			phys:SetVelocity( (self.GoblingSpeed + math.random(1, 92)) * (fwrd + VectorRand()*0.8))
		end
	end
end

function ENT:SetGoopLevel(NewGoopLevel)
	self.GoopLevel = NewGoopLevel
	self.GoopVolume = math.sqrt(NewGoopLevel)
	self:SetDrawScale(self.GoopVolume)
	self.LightBrightness = math.min(100 + 15*NewGoopLevel, 255)
end