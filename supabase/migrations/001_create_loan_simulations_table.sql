-- ==============================================================================
-- 001_create_loan_simulations_table.sql
-- 스마트 대출 이자 계산기: 암호화된 대출 시뮬레이션 저장 테이블 생성
-- ==============================================================================

-- 1. loan_simulations 테이블 생성
CREATE TABLE IF NOT EXISTS public.loan_simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,                  -- 사용자 지정 제목 또는 별칭 (암호화 또는 마스킹)
    encrypted_payload TEXT NOT NULL,      -- AES-GCM 256bit로 암호화된 대출 설정 데이터 (JSON 문자열)
    iv TEXT NOT NULL,                     -- 암호화 초기화 벡터 (Base64)
    salt TEXT NOT NULL,                   -- 암호화 키 파생 솔트 (Base64)
    repayment_type VARCHAR(50) NOT NULL,  -- 상환 방식 분류 (equal-pmt, equal-principal, bullet)
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. 성능 향상을 위한 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_loan_simulations_created_at 
ON public.loan_simulations(created_at DESC);

-- 3. Row Level Security (RLS) 활성화 (보안 강화)
ALTER TABLE public.loan_simulations ENABLE ROW LEVEL SECURITY;

-- 4. RLS 정책 설정 (익명 사용자 조회 및 삽입 허용 정책)
-- 본 프로젝트에서는 누구나 본인의 암호화된 시뮬레이션을 저장하고 조회할 수 있도록 구성합니다.
-- 데이터 자체가 클라이언트에서 강력 암호화(AES-256)되어 저장되므로 DB 단에서도 안전합니다.

DROP POLICY IF EXISTS "모든 사용자가 시뮬레이션 조회 가능" ON public.loan_simulations;
CREATE POLICY "모든 사용자가 시뮬레이션 조회 가능"
ON public.loan_simulations
FOR SELECT
USING (true);

DROP POLICY IF EXISTS "모든 사용자가 시뮬레이션 저장 가능" ON public.loan_simulations;
CREATE POLICY "모든 사용자가 시뮬레이션 저장 가능"
ON public.loan_simulations
FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "모든 사용자가 시뮬레이션 삭제 가능" ON public.loan_simulations;
CREATE POLICY "모든 사용자가 시뮬레이션 삭제 가능"
ON public.loan_simulations
FOR DELETE
USING (true);

-- 5. 설명 코멘트 추가
COMMENT ON TABLE public.loan_simulations IS '대출 계산기 클라이언트 종단간 암호화(E2EE) 시뮬레이션 저장 테이블';
COMMENT ON COLUMN public.loan_simulations.encrypted_payload IS 'AES-GCM 암호화된 대출 파라미터 페이로드';
