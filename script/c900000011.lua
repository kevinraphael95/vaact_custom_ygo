--Guérison de Monstre
function c900000012.initial_effect(c)
	-- Shuffle your hand and monsters into the Deck, then draw same number +1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000012,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c900000012.target)
	e1:SetOperation(c900000012.activate)
	c:RegisterEffect(e1)
end

function c900000012.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_MZONE,0)
		return g:GetCount()>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function c900000012.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_MZONE,0)
	local ct=g:GetCount()
	if ct>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.Draw(tp,ct+1,REASON_EFFECT)
	end
end
