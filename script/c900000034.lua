-- Magie Rapide : Chapeaux Magiques
local s,id=GetID()
function s.initial_effect(c)
	-- Activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Filtre monstre face-up pouvant être Set
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	-- Set le monstre
	Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)

	-- Stocker toutes les Spellbinding Set par cet effet
	local set_cards={}

	-- Set 3 Spellbinding Trap Cards depuis le Deck
	local spellbinding_ids={900000025,900000042} -- Cercle Envoûtant et Illusion Envoûtante
	for i=1,3 do
		local dt=Duel.GetMatchingGroup(function(c) 
			return c:IsCode(900000025,900000042)
		end,tp,LOCATION_DECK,0,nil)
		if #dt==0 then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=dt:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.SSet(tp,sc)
			table.insert(set_cards,sc)
		end
	end

	-- Shuffle les cartes Set
	Duel.ShuffleSetCard(tp)

	-- Effet continu pour protéger/activer les Spellbinding ciblées
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetLabelObject(set_cards)
	e2:SetOperation(s.protect)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	-- Effet continu pour nettoyer si le monstre Set quitte le terrain ou est flip face-up
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetLabelObject({tc,set_cards})
	e3:SetCondition(s.cleanup_condition)
	e3:SetOperation(s.cleanup_operation)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

-- Protection / activation des Spellbinding Set
function s.protect(e,tp,eg,ep,ev,re,r,rp)
	local set_cards=e:GetLabelObject()
	for tc in aux.Next(eg) do
		if tc:IsControler(tp) then
			for _,c in ipairs(set_cards) do
				if c==tc and c:IsOnField() then
					-- Déplacer dans S/T Zone pour activer
					if c:IsType(TYPE_TRAP) and c:IsLocation(LOCATION_MZONE) then
						Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
					else
						Duel.Destroy(c,REASON_EFFECT)
					end
				end
			end
		end
	end
end

-- Condition nettoyage
function s.cleanup_condition(e,tp,eg,ep,ev,re,r,rp)
	local data=e:GetLabelObject()
	local tc=data[1] -- monstre Set
	return not tc:IsOnField() or tc:IsFacedown()==false
end

-- Opération nettoyage
function s.cleanup_operation(e,tp,eg,ep,ev,re,r,rp)
	local data=e:GetLabelObject()
	local set_cards=data[2]
	for _,c in ipairs(set_cards) do
		if c:IsOnField() then
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
