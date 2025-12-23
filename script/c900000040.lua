-- Invocation à la Vitesse de l'Éclair
local s,id=GetID()
function s.initial_effect(c)
	-- Activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Condition de phase
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end

-- Vérifier si tu contrôles les 3 Knights
function s.knightfilter(c)
	return c:IsFaceup() and c:IsCode(25652259,64788463,90876561)
end

-- Filtre pour Level 10 non-DARK
function s.thfilter(c)
	return c:IsLevel(10) and not c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end

-- Target (toujours activable si tu peux Normal Summon)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSummon(tp) end
end

-- Résolution
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local knights=Duel.GetMatchingGroup(s.knightfilter,tp,LOCATION_MZONE,0,nil)

	-- Si tu contrôles les 3 Knights et qu'un Level 10 non-DARK existe
	if #knights==3 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #tg>0 then
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end

	Duel.BreakEffect()

	-- Normal Summon
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sg=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		Duel.Summon(tp,sc,false,nil)
	end
end
