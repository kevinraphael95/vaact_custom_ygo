-- Magicien Bleu Expérimenté
local s,id=GetID()
function s.initial_effect(c)
	-- Permet les Compteurs Magie
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,2)

	-------------------------------------
	-- 1) Ajouter 1 Compteur Magie quand un Spell se résout (max 2)
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.addcounter)
	c:RegisterEffect(e1)

	-------------------------------------
	-- 2) Sacrifice avec 2 compteurs → SS "Gaia le Chevalier Magique"
	-------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-------------------------------------
	-- 3) Depuis le GY : bannir cette carte → +1 compteur sur une cible
	-------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end

-------------------------------------
-- 1) Ajouter un compteur
-------------------------------------
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return end
	if re:IsActiveType(TYPE_SPELL) and c:IsCanAddCounter(0x1,1) and c:GetCounter(0x1)<2 then
		c:AddCounter(0x1,1)
	end
end

-------------------------------------
-- 2) Condition pour sacrifier et invoquer
-------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1)>=2
end

-------------------------------------
-- Filtre pour Gaia le Chevalier Magique (ID 34130561)
-------------------------------------
function s.spfilter(c,e,tp)
	return c:IsCode(34130561) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-------------------------------------
-- Target pour l’invocation
-------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

-------------------------------------
-- Opération pour l’invocation
-------------------------------------
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetCounter(0x1)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_RELEASE)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

-------------------------------------
-- 3) Target pour placer un Compteur depuis le GY
-------------------------------------
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCanAddCounter,0x1),tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end

-------------------------------------
-- Opération pour placer un Compteur depuis le GY
-------------------------------------
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCanAddCounter,0x1),tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then tc:AddCounter(0x1,1) end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
