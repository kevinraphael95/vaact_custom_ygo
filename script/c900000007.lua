-- Magicien Blanc Expérimenté
local s,id=GetID()
function s.initial_effect(c)
	-- Permet les Compteurs Magie
	c:EnableCounterPermit(0x1)

	-------------------------------------
	-- Place 1 Compteur Magie quand une Magie est activée (max 2)
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.addcounter)
	c:RegisterEffect(e1)

	-------------------------------------
	-- Sacrifice avec 2 Compteurs pour invoquer Buster Blader
	-------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-------------------------------------
	-- Bannir depuis le GY pour placer 1 Compteur sur une autre carte
	-------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end

-------------------------------------
-- Placement des Compteurs Magie
-------------------------------------
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) then
		local c=e:GetHandler()
		if c:GetCounter(0x1)<2 then
			c:AddCounter(0x1,1)
		end
	end
end

-------------------------------------
-- Condition pour sacrifier et invoquer
-------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1)>=2
end

-------------------------------------
-- Filtre pour Buster Blader
-------------------------------------
function s.spfilter(c,e,tp)
	return (c:IsCode(78193831) or c:IsCode(78193832) or c:IsCode(78193833)) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-------------------------------------
-- Target pour l’invocation
-------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
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
-- Target pour placer un Compteur depuis le GY
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