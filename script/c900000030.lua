-- Magicien Marron Expérimenté
local s,id=GetID()
function s.initial_effect(c)
	-- Permet les Compteurs Magie
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,1) -- max 1 compteur

	-------------------------------------
	-- Place 1 Compteur quand une Spell Card se résout
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.addcounter)
	c:RegisterEffect(e1)

	-------------------------------------
	-- Retirer 1 compteur pour activer l'effet
	-------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id) -- 1 fois par tour
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

-------------------------------------
-- Placement du compteur
-------------------------------------
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) then
		local c=e:GetHandler()
		if c:GetCounter(0x1)<1 then -- max 1 compteur
			c:AddCounter(0x1,1)
			Duel.Hint(HINT_CARD,0,id) -- message visuel
			Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id,5)) -- optionnel: "Compteur ajouté"
		end
	end
end

-------------------------------------
-- Coût : retirer 1 compteur
-------------------------------------
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	c:RemoveCounter(tp,0x1,1,REASON_COST)
end

-------------------------------------
-- Effet principal
-------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	-- Choisir l'effet
	local op=Duel.SelectOption(tp,
		aux.Stringid(id,1), -- Gain 1500 ATK + Level
		aux.Stringid(id,2)  -- Ajouter carte outside the Duel
	)

	if op==0 then
		-- Gain 1500 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		-- Augmenter le Level de 1
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(1)
		c:RegisterEffect(e2)

	else
		-- Ajouter carte depuis outside the Duel
		local opt=Duel.SelectOption(tp,
			aux.Stringid(id,3), -- Multiply
			aux.Stringid(id,4)  -- Five Star Twilight
		)

		local code = (opt==0) and 900000043 or 900000044
		local tc=Duel.CreateToken(tp,code)
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
