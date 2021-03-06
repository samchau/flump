//
// Flump - Copyright 2012 Three Rings Design

package flump.mold {

import flash.geom.Point;
import flash.geom.Rectangle;

/** @private */
public class AtlasTextureMold
{
    public var symbol :String;
    public var bounds :Rectangle;
    public var offset :Point;

    public static function fromJSON (o :Object) :AtlasTextureMold {
        const mold :AtlasTextureMold = new AtlasTextureMold();
        mold.symbol = require(o, "symbol");
        const rect :Array = require(o, "rect");
        mold.bounds = new Rectangle(rect[0], rect[1], rect[2], rect[3]);
        const off :Array = require(o, "offset");
        mold.offset = new Point(off[0], off[1]);
        return mold;
    }

    public function toJSON (_:*) :Object {
        return {
            symbol: symbol,
            rect: [bounds.x, bounds.y, bounds.width, bounds.height],
            offset: [offset.x, offset.y]
        };
    }

    public function toXML () :XML {
        const json :Object = toJSON(null);
        return <texture name={symbol} rect={json.rect} offset={json.offset}/>;
    }

}
}
