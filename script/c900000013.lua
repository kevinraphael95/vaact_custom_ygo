--Rideau de Magie Noire
function c900000013.initial_effect(c)
	-- Special Summon 1 Spellcaster from Deck, opponent may do the same
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000013,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,900000013)
	e1:SetCost(c900000013.cost)
	e1:SetTarget(c900000013.target)
	e1:SetOperation(c900000013.activate)
	c:RegisterEffect(e1)
end

-- Cost: Pay half LP
function c900000013.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,math.floor(Duel.GetLP(tp)/2)) end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

-- Target: ensure there is a Spellcaster to Special Summon
function c900000013.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c900000013.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c900000013.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Operation: Special Summon for player and optional opponent
function c900000013.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Player summon
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,c900000013.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
	-- Opponent option
	if Duel.IsExistingMatchingCard(c900000013.spfilter,1-tp,LOCATION_DECK,0,1,nil,e,1-tp)
		and Duel.SelectYesNo(1-tp,aux.Stringid(900000013,1)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(1-tp,c900000013.spfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp)
		if g2:GetCount()>0 then
			-- Pay half LP
			local lp_cost = math.floor(Duel.GetLP(1-tp)/2)
			Duel.PayLPCost(1-tp,lp_cost)
			Duel.SpecialSummon(g2,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
