-- Slifer, le Dragon Céleste (Custom propre)
local s,id=GetID()
function s.initial_effect(c)

	-- Nécessite EXACTEMENT 3 Sacrifices pour Invocation Normale / Pose
	aux.AddNormalSummonProcedure(c,true,false,3,3)
	aux.AddNormalSetProcedure(c,true,false,3,3)

	-- Ne peut pas être Sacrifiée
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e1b)

	-- Le contrôle de cette carte ne peut pas changer
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e2)

	-- Non affectée par Magies/Pièges qui feraient quitter le Terrain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.stimmune)
	c:RegisterEffect(e3)

	-- Non affectée par les effets des autres monstres sauf Bête Divine
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.monimmune)
	c:RegisterEffect(e4)

	-- Les effets des autres cartes ne durent qu’1 tour
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.limiteff)
	c:RegisterEffect(e5)

	-- ATK/DEF = cartes en main ×1000
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
	local e6b=e6:Clone()
	e6b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6b)

	-- -2000 ATK aux monstres adverses invoqués en ATK
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetCondition(s.atkcon)
	e7:SetOperation(s.atkop)
	c:RegisterEffect(e7)
	local e7b=e7:Clone()
	e7b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7b)

	-- End Phase : envoyé au Cimetière si Invoqué Spécialement
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetCountLimit(1)
	e8:SetCondition(s.gycon)
	e8:SetOperation(s.gyop)
	c:RegisterEffect(e8)
end

-- ===== Fonctions =====

-- Immunité Magies/Pièges qui feraient quitter le Terrain
function s.stimmune(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and (te:IsHasCategory(CATEGORY_REMOVE)
		or te:IsHasCategory(CATEGORY_TOHAND)
		or te:IsHasCategory(CATEGORY_TODECK)
		or te:IsHasCategory(CATEGORY_TOGRAVE)
		or te:IsHasCategory(CATEGORY_RELEASE))
end

-- Immunité aux monstres sauf Bête Divine
function s.monimmune(e,te)
	return te:IsActiveType(TYPE_MONSTER)
		and not te:GetHandler():IsRace(RACE_DIVINE)
end

-- Effets des autres cartes limités à 1 tour
function s.limiteff(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandler()~=e:GetHandler() then
		re:SetReset(RESET_PHASE+PHASE_END)
	end
end

-- End Phase si Invoqué Spécialement
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummoned()
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
end

-- ATK/DEF
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end

-- Condition -2000 ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsControler(1-tp) and c:IsPosition(POS_FACEUP_ATTACK)
	end,1,nil)
end

-- Application -2000 ATK + destruction
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(function(c)
		return c:IsControler(1-tp) and c:IsPosition(POS_FACEUP_ATTACK)
	end,nil)
	for tc in aux.Next(g) do
		local prev=tc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if prev>0 and tc:GetAttack()==0 then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
