#!/bin/bash
# RunPod 이 컨테이너를 띄울 때 실행하는 진입점.
# 하는 일은 두 가지뿐 — SSH 접속 열기, 그리고 계속 살아있기.

set -e

# RunPod 은 pod 에 등록된 공개키를 PUBLIC_KEY 환경변수로 넣어준다.
if [[ -n "$PUBLIC_KEY" ]]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

# SSH 로그인 세션은 컨테이너 ENV 를 물려받지 않는다 (sshd 가 환경을 새로 만든다).
# 그래서 이미지에 박아둔 UV_*/XLA_* 를 PAM(/etc/environment)과 로그인셸(/etc/profile.d)
# 양쪽에 심어, ssh 로 들어와도 그대로 보이게 한다.
printenv | grep -E "^(UV_|XLA_)" > /tmp/dx-env || true
grep -qxFf /tmp/dx-env /etc/environment 2>/dev/null || cat /tmp/dx-env >> /etc/environment
{ echo '#!/bin/sh'; sed 's/^/export /' /tmp/dx-env; } > /etc/profile.d/dx-env.sh
chmod +x /etc/profile.d/dx-env.sh
rm -f /tmp/dx-env

mkdir -p /run/sshd
ssh-keygen -A                      # 호스트 키가 없으면 생성
/usr/sbin/sshd -D -e &

echo "----------------------------------------------------------"
echo " DX Challenge — Motion Planning"
echo " OS       : $(. /etc/os-release && echo "$PRETTY_NAME")"
echo " Python   : $(python3 --version 2>&1)"
echo " uv       : $(uv --version 2>&1)"
echo " GPU 드라이버: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo '없음')"
echo "----------------------------------------------------------"
echo " 학습 : cd /workspace/dataset/baseline/1_MotionPlanning/V-Max"
echo "        ./.venv/bin/python vmax/scripts/training/train.py ..."
echo " 채점 : cd /workspace/dataset/baseline/1_MotionPlanning/dxchallenge_planning_eval_open"
echo "        ./.venv/bin/python evaluate.py ..."
echo "----------------------------------------------------------"

sleep infinity
