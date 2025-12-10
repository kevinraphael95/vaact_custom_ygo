-- Guérison de Monstre
local s,id=GetID()
function s.initial_effect(c)
	-------------------------------------
	-- Activation : Mélangez toute votre main et vos monstres sur le Terrain dans le Deck ;
	--			  piochez un nombre de cartes égal au nombre de cartes mélangées +1
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-------------------------------------
-- Target pour l’activation
-------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_MZONE,0)
		return g:GetCount()>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-------------------------------------
-- Opération : mélange et pioche
-------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_MZONE,0)
	local ct=g:GetCount()
	if ct>0 then
		-- Envoie toutes les cartes sur le dessus du deck
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		-- Mélange tout le deck
		Duel.ShuffleDeck(tp)
		-- Pioche le nombre de cartes +1
		Duel.Draw(tp,ct+1,REASON_EFFECT)
	end
end
