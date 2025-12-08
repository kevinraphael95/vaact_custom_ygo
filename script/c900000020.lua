--Toile d'Araignée
function c900000020.initial_effect(c)
	-- Target 1 card in opponent's GY sent there last turn, add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000020,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c900000020.target)
	e1:SetOperation(c900000020.activate)
	c:RegisterEffect(e1)
end

function c900000020.filter(c,tp)
	return c:IsAbleToHand() and c:GetTurnID()==Duel.GetTurnCount()-1
end

function c900000020.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c900000020.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c900000020.filter,tp,0,LOCATION_GRAVE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c900000020.filter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function c900000020.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
