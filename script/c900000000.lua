--Monstre Spécial : Flèche Roquette Express
function c900000000.initial_effect(c)
	-- Cannot be Normal Summoned/Set
	c:EnableReviveLimit()

	-- Special Summon from hand if you control no cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c900000000.spcon)
	c:RegisterEffect(e1)

	-- Cannot be Special Summoned by other ways
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(aux.FALSE)
	c:RegisterEffect(e2)

	-- On Special Summon : choose restriction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c900000000.speff)
	c:RegisterEffect(e3)

	-- Standby Phase : destroy unless you send entire hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c900000000.sdcon)
	e4:SetOperation(c900000000.sdop)
	c:RegisterEffect(e4)
end

-- Special Summon condition
function c900000000.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
end

-- After Special Summon : choose restriction
function c900000000.speff(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Les textes viennent du CDB via aux.Stringid
	local op=Duel.SelectOption(tp, aux.Stringid(900000000,0), aux.Stringid(900000000,1))

	-- Option : cannot Battle Phase
	if op==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_BP)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

	-- Option : cannot activate or Set cards
	else
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)

		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_MSET)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)

		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_SSET)
		Duel.RegisterEffect(e4,tp)
	end
end

-- Standby Phase condition
function c900000000.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

-- Standby Phase : choose destroy OR send whole hand
function c900000000.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=hg:GetCount()

	-- No hand => must be destroyed
	if ct==0 then
		Duel.Destroy(c,REASON_EFFECT)
		return
	end

	-- Ask the player : send whole hand?
	local choose = Duel.SelectYesNo(tp, aux.Stringid(900000000,2))

	if choose then
		Duel.SendtoGrave(hg,REASON_EFFECT)
	else
		Duel.Destroy(c,REASON_EFFECT)
	end
end
