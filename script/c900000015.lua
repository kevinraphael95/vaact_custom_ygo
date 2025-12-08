--Cercueil Maléfique
function c900000015.initial_effect(c)
	-- Trigger on opponent's Normal or Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000015,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
	e1:SetCountLimit(1,900000015)
	e1:SetCondition(c900000015.condition)
	e1:SetTarget(c900000015.target)
	e1:SetOperation(c900000015.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end

-- Condition: opponent summoned a monster
function c900000015.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end

-- Target 1 opponent monster and 1 your monster
function c900000015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		   and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1+g2,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

-- Operation: send both to GY and optionally Special Summon
function c900000015.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:GetCount()<2 then return end
	local g1=tg:Filter(Card.IsControler,nil,1-tp)
	local g2=tg:Filter(Card.IsControler,nil,tp)
	if Duel.SendtoGrave(g1+g2,REASON_EFFECT)~=0 then
		local tc=g2:GetFirst() -- your monster
		local sptg=nil
		if g1:GetFirst():IsRace(RACE_SPELLCASTER) then
			-- opponent's monster was Spellcaster: Special Summon it from Deck
			sptg=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetCode())
		else
			-- Otherwise Special Summon Spellcaster from GY
			sptg=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_GRAVE,0,1,1,nil,RACE_SPELLCASTER)
		end
		if sptg and sptg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(sptg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
