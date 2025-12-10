--Flèche Roquette Express
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()

	------------------------------
	-- Cannot be Normal Summoned/Set
	------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)

	------------------------------
	-- Special Summon from hand if you control no cards
	------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	------------------------------
	-- Cannot be Special Summoned except by its own procedure
	------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)

	------------------------------
	-- On Special Summon : choose restriction
	------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.speff)
	c:RegisterEffect(e3)

	------------------------------
	-- Standby Phase : destroy unless you send whole hand
	------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.sdcon)
	e4:SetOperation(s.sdop)
	c:RegisterEffect(e4)
end

-- Special Summon condition : you control no cards
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
end

-- "Cannot be Special Summoned except by its own effect"
function s.splimit(e,se,sp,st)
	return se:GetHandler()==e:GetHandler()
end

-- After Special Summon : choose one restriction
function s.speff(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re or not re:GetHandler()==c then return end

	local op=Duel.SelectOption(tp,
		aux.Stringid(id,0),  -- "You cannot conduct your Battle Phase this turn."
		aux.Stringid(id,1))  -- "You cannot activate or Set other cards this turn."

	if op==0 then
		---------------------------------------
		-- Cannot conduct your Battle Phase
		---------------------------------------
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_BP)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

	else
		---------------------------------------
		-- Cannot activate cards/effects
		---------------------------------------
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(1,0)
		e2:SetValue(s.aclimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)

		---------------------------------------
		-- Cannot Set cards
		---------------------------------------
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_MSET)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)

		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_SSET)
		Duel.RegisterEffect(e4,tp)

		---------------------------------------
		-- Cannot Normal Summon
		---------------------------------------
		local e5=e3:Clone()
		e5:SetCode(EFFECT_CANNOT_SUMMON)
		Duel.RegisterEffect(e5,tp)

		---------------------------------------
		-- Cannot Special Summon
		---------------------------------------
		local e6=e3:Clone()
		e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e6,tp)
	end
end

function s.aclimit(e,re,tp)
	return true
end

-- Standby Phase (your)
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

-- Destroy unless sending whole hand
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #hg==0 then
		Duel.Destroy(c,REASON_EFFECT)
		return
	end

	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.SendtoGrave(hg,REASON_EFFECT)
	else
		Duel.Destroy(c,REASON_EFFECT)
	end
end
