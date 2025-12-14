--Dé-Fusion
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: return 1 Fusion Monster to Extra Deck, then Special Summon its materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Filtre : monstre Fusion pouvant retourner dans l'Extra Deck
function s.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end

-- Cible un monstre Fusion sur le Terrain
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then 
		return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc)
	end
	if chk==0 then 
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

-- Résolution de l'effet
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	-- Récupère les matériaux originaux de la Fusion
	local mats=tc:GetMaterial()
	if not mats or #mats==0 then return end

	-- Déplace le Fusion Monster dans l'Extra Deck
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end

	-- Vérifie que tous les matériaux sont au cimetière, sinon on les y envoie
	local ready={}
	for _,mc in ipairs(mats) do
		if mc:IsLocation(LOCATION_ONFIELD) or mc:IsLocation(LOCATION_HAND) then
			Duel.SendtoGrave(mc,REASON_EFFECT)
		end
		if mc:IsLocation(LOCATION_GRAVE) then
			table.insert(ready,mc)
		end
	end

	-- Special Summon si assez de zones
	local freezones=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #ready>0 and freezones>0 then
		local toSummon={}
		for i,mc in ipairs(ready) do
			if i>freezones then break end
			table.insert(toSummon,mc)
		end
		for _,mc in ipairs(toSummon) do
			Duel.SpecialSummonStep(mc,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end
