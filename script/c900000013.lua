-- Rideau de Magie Noire
local s,id=GetID()
function s.initial_effect(c)
	-------------------------------------
	-- Activation : Invoquez Spécialement 1 monstre Magicien depuis votre Deck,
	--			  l'adversaire peut choisir de faire de même
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-------------------------------------
-- Coût : payer la moitié des LP
-------------------------------------
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.CheckLPCost(tp,math.floor(Duel.GetLP(tp)/2)) 
	end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

-------------------------------------
-- Filtre : monstre Magicien invocable
-------------------------------------
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-------------------------------------
-- Target pour l’activation
-------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-------------------------------------
-- Opération : Invoquer le joueur et l'adversaire si choix
-------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Joueur
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end

	-- Adversaire peut choisir de payer la moitié de ses LP pour invoquer
	if Duel.IsExistingMatchingCard(s.spfilter,1-tp,LOCATION_DECK,0,1,nil,e,1-tp)
		and Duel.CheckLPCost(1-tp,math.floor(Duel.GetLP(1-tp)/2))
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		local lp_cost = math.floor(Duel.GetLP(1-tp)/2)
		Duel.PayLPCost(1-tp,lp_cost)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(1-tp,s.spfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp)
		if g2:GetCount()>0 then
			Duel.SpecialSummon(g2,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
