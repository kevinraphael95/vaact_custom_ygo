-- Carte d'Inviolabilité
local s,id=GetID()
function s.initial_effect(c)
	-------------------------------------
	-- Chaque joueur pioche jusqu'à avoir 6 cartes
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-------------------------------------
-- Target pour l'activation
-------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,0)
end

-------------------------------------
-- Opération : chaque joueur pioche jusqu'à 6 cartes
-------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local draw_count = 6 - Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
		if draw_count > 0 then
			Duel.Draw(p,draw_count,REASON_EFFECT)
		end
	end
end
