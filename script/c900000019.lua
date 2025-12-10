--Double Sort
local s,id=GetID()
function s.initial_effect(c)
	-- Target 1 Spell in opponent's GY and use its effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	-- Utilisation d'une catégorie valide
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand() -- check pour éviter les cas invalides
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then 
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.filter(chkc)
	end
	if chk==0 then 
		return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- Remplacement de CATEGORY_TOFIELD par CATEGORY_LEAVE_GRAVE pour éviter l'erreur
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	local zone=LOCATION_SZONE
	if tc:IsType(TYPE_FIELD) then zone=LOCATION_FZONE end

	-- Place la carte sur ton Terrain
	if not Duel.MoveToField(tc,tp,tp,zone,POS_FACEUP,true) then return end

	-- Applique son effet d’activation
	local te=tc:GetActivateEffect()
	if not te then return end
	
	local tg=te:GetTarget()
	local op=te:GetOperation()

	-- exécute la cible si elle existe
	if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end

	-- exécute l’effet
	if op then op(te,tp,eg,ep,ev,re,r,rp) end

	-- Si c'est une Magie Normale → cimetière après résolution
	if tc:IsType(TYPE_SPELL) and not tc:IsType(TYPE_CONTINUOUS+TYPE_FIELD) then
		Duel.SendtoGrave(tc,REASON_RULE)
	end
end
