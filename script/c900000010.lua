--Carte d'Inviolabilité
function c900000010.initial_effect(c)
	-- Each player draws until they have 6 cards
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c900000010.target)
	e1:SetOperation(c900000010.activate)
	c:RegisterEffect(e1)
end

function c900000010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,0)
end

function c900000010.activate(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local draw_count = 6 - Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
		if draw_count > 0 then
			Duel.Draw(p,draw_count,REASON_EFFECT)
		end
	end
end
