-- Magie Rapide : Échange
local s,id=GetID()
function s.initial_effect(c)
	-- Activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local hg1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local hg2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)

	if #hg1==0 or #hg2==0 then return end

	-- Révéler les mains
	Duel.ConfirmCards(tp,hg2)
	Duel.ConfirmCards(1-tp,hg1)

	-- Choisir une carte de la main de l'autre joueur
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg1=hg2:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	local sg2=hg1:Select(1-tp,1,1,nil)

	if sg1:GetFirst() and sg2:GetFirst() then
		-- Retirer temporairement du jeu pour pouvoir utiliser SendtoHand
		Duel.Remove(sg1:GetFirst(),POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
		Duel.Remove(sg2:GetFirst(),POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)

		-- Ajouter dans la main du joueur adverse
		Duel.SendtoHand(sg1:GetFirst(),tp,REASON_EFFECT)
		Duel.SendtoHand(sg2:GetFirst(),1-tp,REASON_EFFECT)
	end

	-- Mélanger les mains
	Duel.ShuffleHand(tp)
	Duel.ShuffleHand(1-tp)
end
