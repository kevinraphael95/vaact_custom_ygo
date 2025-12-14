-- Cercueil Maléfique
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end

-- Filtres
function s.opp(c)
	return c:IsAbleToGrave()
end
function s.own(c)
	return c:IsAbleToGrave()
end
function s.magician(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Ciblage
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingTarget(s.opp,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsExistingTarget(s.own,tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.opp,tp,0,LOCATION_MZONE,1,1,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.own,tp,LOCATION_MZONE,0,1,1,nil)

	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
end

-- Résolution
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #g~=2 then return end

	local opp=g:Filter(Card.IsControler,nil,1-tp):GetFirst()

	Duel.SendtoGrave(g,REASON_EFFECT)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local canGY=Duel.IsExistingMatchingCard(s.magician,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local canDeck=opp:IsRace(RACE_SPELLCASTER)
		and Duel.IsExistingMatchingCard(s.magician,tp,LOCATION_DECK,0,1,nil,e,tp)

	if not canGY and not canDeck then return end

	-- Demande si le joueur veut invoquer
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end

	local loc=LOCATION_GRAVE -- par défaut Cimetière

	-- Si les deux sont possibles, proposer le choix
	if canGY and canDeck then
		local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		if op==1 then loc=LOCATION_DECK end
	elseif canDeck then
		loc=LOCATION_DECK
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.magician,tp,loc,0,1,1,nil,e,tp)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end