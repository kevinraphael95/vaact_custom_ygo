--Correspondance
local s,id=GetID()

function s.initial_effect(c)
	---------------------------------
	-- Activation : Equiper un Machine EARTH
	---------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	---------------------------------
	-- Equip limit : Machine + EARTH
	---------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
end

---------------------------------
-- Equip limit : Machine + EARTH
---------------------------------
function s.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end

---------------------------------
-- Filters
---------------------------------
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end

function s.costfilter(c)
	return c:IsRace(RACE_MACHINE) and c:GetLevel()>=4 and c:IsAbleToRemoveAsCost()
end

---------------------------------
-- Target : select monster + check cost
---------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then 
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_GRAVE)
end

---------------------------------
-- Operation : banish 2 Machines (Lvl 4+) then equip
---------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

	-- pay cost
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if #g<2 or Duel.Remove(g,POS_FACEUP,REASON_COST)==0 then return end

	-- Equip
	if not Duel.Equip(tp,c,tc) then return end

	--------------------------------------------------------------
	-- Double ATK
	--------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(tc:GetBaseAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)

	--------------------------------------------------------------
	-- Piercing (effet de perçage)
	--------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)

	--------------------------------------------------------------
	-- Other monsters cannot attack
	--------------------------------------------------------------
	local fid=tc:GetFieldID()
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return c:GetFieldID()~=e:GetLabel() end)
	e3:SetLabel(fid)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	Duel.RegisterEffect(e3,tp)
end
