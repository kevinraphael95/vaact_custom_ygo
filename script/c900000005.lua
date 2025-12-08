--Slifer, le Dragon Céleste
function c900000005.initial_effect(c)
	--Requires 3 Tributes to Normal Summon/Set
	c:EnableReviveLimit()
	--Cannot be Tributed
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UNRELEASABLE_SUM)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e00=e0:Clone()
	e00:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e00)

	--Cannot change control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e1)

	--Unaffected by Spells/Traps that would make it leave field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgval)
	c:RegisterEffect(e2)

	--Unaffected by other monsters' effects except Divine-Beasts
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(c900000005.efilter)
	c:RegisterEffect(e3)

	--Send to GY if Special Summoned during End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c900000005.gycon)
	e4:SetOperation(c900000005.gyop)
	c:RegisterEffect(e4)

	--Gain 1000 ATK/DEF per card in hand
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c900000005.atkval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)

	--Opponent monsters summoned in ATK lose 2000 ATK, destroy if 0
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetRange(LOCATION_MZONE)
	e7:SetOperation(c900000005.atkop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e8)
end

--Immune to monster effects except Divine-Beast
function c900000005.efilter(e,te)
	local tc=te:GetOwner()
	return tc:IsType(TYPE_MONSTER) and not tc:IsRace(RACE_DIVINE)
end

--Check if Special Summoned
function c900000005.gycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function c900000005.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
end

--ATK/DEF boost per card in hand
function c900000005.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end

--Opponent monsters lose 2000 ATK
function c900000005.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	for tc in aux.Next(g) do
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			local atk=tc:GetAttack()
			local val=math.min(2000,atk)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-val)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetAttack()==0 then
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end
