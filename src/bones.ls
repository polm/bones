export R = -> ~~(it * Math.random!)
export pick = -> it[R it.length]

# fisher yates shuffle
# https://bost.ocks.org/mike/shuffle/
export shuffle = ->
  deck = it.slice 0

  mi = deck.length
  while mi > 0
    mi -= 1
    ri = R mi
    t = deck[mi]
    deck[mi] = deck[ri]
    deck[ri] = t

  return deck

export make-grid = (width, height, init) ->
  height = height or width

  grid = []
  for ii from 0 til width
    grid.push []
    for jj from 0 til height
      grid[ii].push {}
      init? grid[ii][jj], ii, jj

  return grid

class Point
  (@x, @y) ~>

  eq: ~>
    return @x == it.x and @y == it.y

  add: ~>
    @x += it.x
    @y += it.y
    return this

  sub: ~>
    @x -= it.x
    @y -= it.y
    return this

  mul: (x, y) ~>
    y = y or x
    @x *= x
    @y *= y
    return this

  dist: ~>
    Math.sqrt ((it.x - @x) ^ 2) + ((it.y - @y) ^ 2)

UP    = Point  0, -1
DOWN  = Point  0,  1
LEFT  = Point -1,  0
RIGHT = Point  1,  0

UP.name    = \up
DOWN.name  = \down
LEFT.name  = \left
RIGHT.name = \right

# convert a x1,y1,x2,y2 rect to a x,y,w,h rect
rect-conv = ->
  Rect it.x, it.y, (it.x2 - it.x), (it.y2 - it.y)

class Rect extends Point
  (@x, @y, @w, @h) ~>

  coll: ~>
    return (@x < it.x + it.w and
        @x + @w > it.x and
        @y < it.y + it.h and
        @y + it.h > it.y)

get-neighbors = (grid, node) ->
  w = grid.length
  h = grid.0.length
  x = node.x
  y = node.y

  n = []
  if x > 0 then n.push [grid[x - 1][y], \right]
  if x < w - 1 then n.push [grid[x + 1][y], \left]
  if y > 0 then n.push [grid[x][y - 1], \down]
  if y < h - 1 then n.push [grid[x][y + 1], \up]
  return n

DIRS =
  right: RIGHT
  left: LEFT
  up: UP
  down: DOWN


opposite-dir = ->
  switch it
  | \right => \left
  | \left  => \right
  | \up    => \down
  | \down  => \up

# dfs for maze generation
export dfs-maze = (grid) ->
  candidates = [ [grid[0][0], null ] ] # points yet to be visited

  while candidates.length > 0
    [cn, dir] = candidates.pop!
    if cn.visited then continue

    if dir # false for first node
      pdir = DIRS[dir]
      parent = grid[cn.x + pdir.x][cn.y + pdir.y]

      cn.visited = true
      cn[dir] = parent

      parent[opposite-dir dir] = cn

    neighbors = shuffle get-neighbors grid, cn
    for nn in neighbors
      candidates.push nn

  return grid

print-maze = (grid) ->
  for yy from 0 til grid.0.length
    t = ''
    m = ''
    b = ''
    for xx from 0 til grid.length
      ud = (grid[xx][yy].up    and ' ') or \#
      dd = (grid[xx][yy].down  and ' ') or \#
      ld = (grid[xx][yy].left  and ' ') or \#
      rd = (grid[xx][yy].right and ' ') or \#
      t += "##ud#"
      m += "#ld #rd"
      b += "##dd#"
    console.log t
    console.log m
    console.log b

grid = make-grid 10, 5, (c,x,y) ->
  c.x = x
  c.y = y

print-maze dfs-maze grid
