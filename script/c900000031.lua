-- Chevalier du Valet
local s,id=GetID()
function s.initial_effect(c)
	-- Invocation Normale sans Sacrifice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)

	-- Devient Niveau 4
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(4)
	e2:SetCondition(s.lvcon)
	c:RegisterEffect(e2)

	-- ATK d'origine devient 1800
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetValue(1800)
	e3:SetCondition(s.lvcon)
	c:RegisterEffect(e3)
end

-- Condition : Invocation Normale sans Sacrifice
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0
end

-- Condition appliquée uniquement si invoqué sans Sacrifice
function s.lvcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_NORMAL
		and e:GetHandler():GetMaterialCount()==0
end
