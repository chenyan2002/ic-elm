import BigNumber from 'bignumber.js';
import { IDL, CanisterId } from '@dfinity/agent';

export function normalizeReturn(types, res) {
  let result;
  if (types.length === 0) {
    result = [];
  } else if (types.length === 1) {
    result = [res];
  } else {
    result = res;
  }
  return result;
}


class CandidWalker extends IDL.Visitor {
  constructor(toJSON) {
    super();
    if (typeof toJSON !== 'boolean') {
      throw new Error('unknown flag');
    }
    this._toJSON = toJSON;
  }
  visitPrimitive(t, v) {
    return v;
  }
  visitNumber(t, v) {
    if (this._toJSON) {
      return v.toFixed();
    } else {
      return new BigNumber(v);
    }
  }
  visitFixedInt(t, v) {
    if (this._toJSON && t._bits <= 32) {
        return v;
    } else {
      return this.visitNumber(t, v);
    }
  }
  visitFixedNat(t, v) {
    return this.visitFixedInt(t, v);
  }
  visitPrincipal(t, v) {
    if (this._toJSON) {
      return v.toText();
    } else {
      return canisterId.fromText(v);
    }
  }
  visitService(t, v) {
    return this.visitPrincipal(t, v);
  }
  visitFunc(t, v) {
    return [this.visitPrincipal(t, v[0]), v[1]];
  }
  visitVec(t, ty, v) {
    return v.map(val => walker(ty, this._toJSON, val));
  }
  visitOpt(t, ty, v) {
    if (v.length === 0) {
      return v;
    }
    return [walker(ty, this._toJSON, v[0])];
  }
  visitRecord(t, fields, v) {
    const res = {};
    fields.forEach(([key, type], i) => {
      res[key] = walker(type, this._toJSON, v[key]);
    });
    return res;
  }
  visitVariant(t, fields, v) {
    const res = {};
    const selected = Object.entries(v)[0];
    fields.forEach(([key, type]) => {
      if (key === selected[0]) {
        res[key] = walker(type, this._toJSON, selected[1]);
        return res;
      }
    });
    throw new Error('bad variant value');
  }
  visitRec(t, ty, v) {
    return walker(ty, this._toJSON, v);
  }
}

function walker(t, toJSON, v) {
  return t.accept(new CandidWalker(toJSON), v);
}

export function toJSON(t, v) {
  return walker(t, true, v);
}
export function fromJSON(t, v) {
  return walker(t, false, v);
}
