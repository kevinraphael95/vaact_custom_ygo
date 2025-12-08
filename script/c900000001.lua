-- Correspondance
function c900000001.initial_effect(c)
	-- Must be equipped to an EARTH Machine monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c900000001.target)
	e1:SetOperation(c900000001.operation)
	c:RegisterEffect(e1)

	-- Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c900000001.eqlimit)
	c:RegisterEffect(e2)
end

-- Equip limit function
function c900000001.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end

-- Target: must banish 2 Level 4+ Machine monsters from GY
function c900000001.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end

function c900000001.costfilter(c)
	return c:IsRace(RACE_MACHINE) and c:GetLevel()>=4 and c:IsAbleToRemoveAsCost()
end

function c900000001.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c900000001.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c900000001.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c900000001.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c900000001.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_GRAVE)
end

function c900000001.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.IsExistingMatchingCard(c900000001.costfilter,tp,LOCATION_GRAVE,0,2,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c900000001.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
		if g:GetCount()<2 then return end
		if Duel.Remove(g,POS_FACEUP,REASON_COST)~=0 then
			Duel.Equip(tp,c,tc)
			-- Double ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetBaseAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			-- Piercing
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_PIERCE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
			-- Other monsters cannot attack
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetTargetRange(LOCATION_MZONE,0)
			e3:SetTarget(c900000001.atktarget)
			e3:SetLabel(tc:GetFieldID())
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			Duel.RegisterEffect(e3,tp)
		end
	end
end

-- Only other monsters cannot attack
function c900000001.atktarget(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
