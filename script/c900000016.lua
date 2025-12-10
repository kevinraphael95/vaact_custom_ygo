-- Sélection Naturelle
local s,id=GetID()
function s.initial_effect(c)
	-- Activation only during opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Condition : uniquement pendant le tour adverse
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

-- Cible un monstre face recto contrôlé par l'adversaire
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then 
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup()
	end
	if chk==0 then 
		return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	-- On copie les stats
	local lv=tc:GetLevel()
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	local race=tc:GetRace()
	local att=tc:GetAttribute()

	-- On crée le jeton (ID séparé)
	local token=Duel.CreateToken(tp,900000025)
	if not token then return end

	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)

	-- Copie des stats
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(def)
	token:RegisterEffect(e2)

	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(att)
	token:RegisterEffect(e3)

	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(race)
	token:RegisterEffect(e4)

	local e5=e1:Clone()
	e5:SetCode(EFFECT_CHANGE_LEVEL)
	e5:SetValue(lv)
	token:RegisterEffect(e5)

	Duel.SpecialSummonComplete()

	-- Destruction du jeton en End Phase
	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetLabelObject(token)
	e6:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local tc=e:GetLabelObject()
		if tc and tc:IsOnField() then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end)
	e6:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e6,tp)
end
